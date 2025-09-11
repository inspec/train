require "train/plugins"
require "json" unless defined?(JSON)
require "yaml" unless defined?(YAML)
require "base64" unless defined?(Base64)
require "open3" unless defined?(Open3)
require "timeout" unless defined?(Timeout)

module Train::Transports
  class Kubernetes < Train.plugin(1)
    name "kubernetes"

    # Configuration options for Kubernetes transport
    option :kubeconfig_path, default: File.expand_path("~/.kube/config")
    option :cluster_endpoint, default: nil
    option :namespace, default: "default"
    option :timeout, default: 30

    def connection(_ = nil)
      @connection ||= Connection.new(@options)
    end

    class Connection < BaseConnection
      attr_reader :options

      def initialize(options)
        super(options)

        @kubeconfig_path = @options[:kubeconfig_path]
        @cluster_endpoint = @options[:cluster_endpoint]
        @namespace = @options[:namespace]
        @timeout = @options[:timeout]

        # Validate kubeconfig exists and is readable
        validate_kubeconfig

        # Set platform details
        @platform_details = {
          release: detect_kubernetes_version,
          name: "kubernetes",
          family: "cloud",
        }

        connect
      end

      def platform
        # Ensure kubernetes platform is registered in families
        Train::Platforms::Detect::Specifications::Api.load

        # Register kubernetes in cloud family if not already registered
        k8s_platform = Train::Platforms.list["kubernetes"]
        if k8s_platform.nil? || k8s_platform.families.empty?
          Train::Platforms.name("kubernetes").in_family("cloud")
        end

        plat = force_platform!("kubernetes", @platform_details)
        plat.find_family_hierarchy
        plat
      end

      def connect
        # Validate kubectl is available
        unless kubectl_available?
          raise Train::TransportError, "kubectl command not found. Please install kubectl."
        end

        # Test connection by trying to access cluster info
        test_connection
      rescue StandardError => e
        raise Train::TransportError, "Failed to connect to Kubernetes cluster: #{e.message}"
      end

      def uri
        endpoint = @cluster_endpoint || extract_cluster_endpoint
        "kubernetes://#{endpoint || "unknown"}"
      end

      def unique_identifier
        endpoint = @cluster_endpoint || extract_cluster_endpoint
        "kubernetes:#{endpoint}:#{@namespace}"
      end

      def close
        # No persistent connection to close for kubectl-based transport
      end

      private

      def validate_kubeconfig
        return if @cluster_endpoint # Skip kubeconfig validation if cluster endpoint is provided

        unless File.exist?(@kubeconfig_path)
          raise Train::TransportError, "Kubeconfig file not found at #{@kubeconfig_path}"
        end

        unless File.readable?(@kubeconfig_path)
          raise Train::TransportError, "Kubeconfig file not readable at #{@kubeconfig_path}"
        end
      end

      def kubectl_available?
        Open3.popen3("kubectl version --client=true") do |_stdin, _stdout, _stderr, wait_thr|
          wait_thr.value.success?
        end
      rescue StandardError
        false
      end

      def test_connection
        cmd = build_kubectl_command(["cluster-info"])
        result = execute_kubectl_command(cmd)

        if result.exit_status != 0
          raise Train::TransportError, "Unable to connect to cluster: #{result.stderr}"
        end
      end

      def detect_kubernetes_version
        cmd = build_kubectl_command(["version", "--short=true"])
        result = execute_kubectl_command(cmd)

        if result.exit_status == 0
          # Parse version from output
          result.stdout.lines.each do |line|
            if line.include?("Server Version:")
              return line.split(":").last.strip
            end
          end
        end

        "unknown"
      rescue StandardError
        "unknown"
      end

      def extract_cluster_endpoint
        return @cluster_endpoint if @cluster_endpoint

        begin
          kubeconfig = YAML.load_file(@kubeconfig_path)
          current_context = kubeconfig["current-context"]
          return nil unless current_context

          context = kubeconfig["contexts"]&.find { |c| c["name"] == current_context }
          return nil unless context

          cluster_name = context["context"]["cluster"]
          cluster = kubeconfig["clusters"]&.find { |c| c["name"] == cluster_name }
          return nil unless cluster

          server = cluster["cluster"]["server"]
          URI.parse(server).host if server
        rescue StandardError
          nil
        end
      end

      def build_kubectl_command(args)
        cmd = ["kubectl"]

        # Add kubeconfig if specified and not using cluster endpoint
        if @kubeconfig_path && !@cluster_endpoint
          cmd += ["--kubeconfig", @kubeconfig_path]
        end

        # Add cluster endpoint if specified
        if @cluster_endpoint
          cmd += ["--server", @cluster_endpoint]
        end

        # Add namespace if not default
        if @namespace && @namespace != "default"
          cmd += ["--namespace", @namespace]
        end

        cmd + args
      end

      def execute_kubectl_command(cmd)
        stdout_str = ""
        stderr_str = ""
        exit_status = 0

        Open3.popen3(*cmd) do |stdin, stdout, stderr, wait_thr|
          stdin.close

          # Set timeout
          if @timeout && @timeout > 0
            begin
              Timeout.timeout(@timeout) do
                stdout_str = stdout.read
                stderr_str = stderr.read
                exit_status = wait_thr.value.exitstatus
              end
            rescue Timeout::Error
              Process.kill("KILL", wait_thr.pid)
              raise Train::CommandTimeoutReached, "kubectl command timed out after #{@timeout} seconds"
            end
          else
            stdout_str = stdout.read
            stderr_str = stderr.read
            exit_status = wait_thr.value.exitstatus
          end
        end

        Train::Extras::CommandResult.new(stdout_str, stderr_str, exit_status)
      rescue StandardError => e
        Train::Extras::CommandResult.new("", e.message, 1)
      end

      def run_command_via_connection(cmd, opts = {})
        # Parse kubectl commands vs direct execution
        if cmd.start_with?("kubectl ")
          # Extract kubectl arguments
          kubectl_args = cmd.split(" ")[1..-1]
          kubectl_cmd = build_kubectl_command(kubectl_args)
          execute_kubectl_command(kubectl_cmd)
        else
          # For non-kubectl commands, we can't execute them directly
          # Return an error indicating this transport only supports kubectl operations
          Train::Extras::CommandResult.new(
            "",
            "Kubernetes transport only supports kubectl operations. Use 'kubectl ...' commands.",
            1
          )
        end
      end

      def file_via_connection(path, *args)
        KubernetesFile.new(self, path, *args)
      end

      # Helper method to parse Kubernetes resource paths
      def parse_resource_path(path)
        # Parse paths like:
        # /configmap/namespace/name/key
        # /secret/namespace/name/key
        # /logs/namespace/pod-name
        parts = path.split("/").reject(&:empty?)

        return nil if parts.empty?

        {
          resource_type: parts[0],
          namespace: parts[1],
          name: parts[2],
          key: parts[3],
        }
      end

      # Kubernetes-specific file class
      class KubernetesFile < Train::File
        def initialize(backend, path, follow_symlink = true)
          super(backend, path, follow_symlink)
          @resource_info = @backend.send(:parse_resource_path, path)
        end

        def exist?
          return false unless @resource_info

          case @resource_info[:resource_type]
          when "configmap", "secret"
            check_resource_exists
          when "logs"
            check_pod_exists
          else
            false
          end
        end

        def content
          return nil unless exist?

          case @resource_info[:resource_type]
          when "configmap"
            get_configmap_content
          when "secret"
            get_secret_content
          when "logs"
            get_pod_logs
          else
            nil
          end
        end

        def size
          content&.bytesize || 0
        end

        def mtime
          # For Kubernetes resources, return current time
          Time.now.to_i
        end

        def mode
          0644 # Default file mode for Kubernetes resources
        end

        def owner
          "kubernetes"
        end

        def group
          "kubernetes"
        end

        def uid
          0
        end

        def gid
          0
        end

        def type
          :file
        end

        def selinux_label
          nil
        end

        private

        def check_resource_exists
          cmd = case @resource_info[:resource_type]
                when "configmap"
                  ["get", "configmap", @resource_info[:name], "-n", @resource_info[:namespace]]
                when "secret"
                  ["get", "secret", @resource_info[:name], "-n", @resource_info[:namespace]]
                end

          result = @backend.send(:execute_kubectl_command, @backend.send(:build_kubectl_command, cmd))
          result.exit_status == 0
        end

        def check_pod_exists
          cmd = ["get", "pod", @resource_info[:name], "-n", @resource_info[:namespace]]
          result = @backend.send(:execute_kubectl_command, @backend.send(:build_kubectl_command, cmd))
          result.exit_status == 0
        end

        def get_configmap_content
          cmd = ["get", "configmap", @resource_info[:name], "-n", @resource_info[:namespace], "-o", "yaml"]
          result = @backend.send(:execute_kubectl_command, @backend.send(:build_kubectl_command, cmd))

          return nil if result.exit_status != 0

          begin
            configmap = YAML.safe_load(result.stdout)
            data = configmap.dig("data", @resource_info[:key])
            data
          rescue StandardError
            nil
          end
        end

        def get_secret_content
          cmd = ["get", "secret", @resource_info[:name], "-n", @resource_info[:namespace], "-o", "yaml"]
          result = @backend.send(:execute_kubectl_command, @backend.send(:build_kubectl_command, cmd))

          return nil if result.exit_status != 0

          begin
            secret = YAML.safe_load(result.stdout)
            encoded_data = secret.dig("data", @resource_info[:key])
            return nil unless encoded_data

            Base64.decode64(encoded_data)
          rescue StandardError
            nil
          end
        end

        def get_pod_logs
          cmd = ["logs", @resource_info[:name], "-n", @resource_info[:namespace]]
          result = @backend.send(:execute_kubectl_command, @backend.send(:build_kubectl_command, cmd))

          result.exit_status == 0 ? result.stdout : nil
        end
      end
    end
  end
end
