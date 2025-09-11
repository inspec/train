require "helper"
require "train/transports/kubernetes"

describe "kubernetes transport" do
  let(:cls) { Train::Transports::Kubernetes }
  let(:transport) { cls.new(options) }

  let(:default_options) do
    {
      kubeconfig_path: File.expand_path("~/.kube/config"),
      namespace: "default",
      timeout: 30,
    }
  end

  let(:options) { default_options }

  before do
    # Load API specifications to ensure family hierarchy is set up
    Train::Platforms::Detect::Specifications::Api.load

    # Clear any existing kubernetes platform to avoid conflicts
    Train::Platforms.list["kubernetes"] = nil

    # Register kubernetes in the cloud family (which is in api family)
    Train::Platforms.name("kubernetes").in_family("cloud")

    # Set up default successful mocks for all tests
    setup_mocks
  end

  def setup_mocks
    # Mock file system checks
    File.stubs(:exist?).returns(true)
    File.stubs(:readable?).returns(true)

    # Mock kubectl availability check using new format
    Open3.stubs(:capture3).with("kubectl", "version", "--client", "--output=json").returns(
      ['{"clientVersion":{"major":"1","minor":"20"}}', "", stub(success?: true)]
    )

    # Mock YAML.load_file for kubeconfig
    YAML.stubs(:load_file).returns(mock_kubeconfig)

    # Mock Open3.popen3 for all kubectl commands
    Open3.stubs(:popen3).returns([nil, mock_io("test output"), mock_io(""), mock_wait_thread(true, 0)])
  end

  def mock_wait_thread(success = true, exit_status = 0)
    thread = mock("wait_thread")
    process_status = mock("process_status")
    process_status.stubs(:success?).returns(success)
    process_status.stubs(:exitstatus).returns(exit_status)
    thread.stubs(:value).returns(process_status)
    thread.stubs(:pid).returns(12345)
    thread
  end

  def mock_io(content)
    io = mock("io")
    io.stubs(:read).returns(content)
    io.stubs(:close)
    io
  end

  def mock_kubeconfig
    {
      "current-context" => "test-context",
      "contexts" => [
        {
          "name" => "test-context",
          "context" => {
            "cluster" => "test-cluster",
            "user" => "test-user",
          },
        },
      ],
      "clusters" => [
        {
          "name" => "test-cluster",
          "cluster" => {
            "server" => "https://test-cluster.example.com:6443",
          },
        },
      ],
      "users" => [
        {
          "name" => "test-user",
          "user" => {
            "token" => "test-token",
          },
        },
      ],
    }
  end

  before do
    setup_mocks
  end

  describe "plugin" do
    it "inherits from the train plugin version 1" do
      _(cls.ancestors).must_include Train::Plugins::Transport
    end

    it "has the correct plugin name" do
      _(Train::Plugins.registry["kubernetes"]).must_equal cls
    end
  end

  describe "default options" do
    it "sets default kubeconfig path" do
      _(transport.options[:kubeconfig_path]).must_equal File.expand_path("~/.kube/config")
    end

    it "sets default namespace" do
      _(transport.options[:namespace]).must_equal "default"
    end

    it "sets default timeout" do
      _(transport.options[:timeout]).must_equal 30
    end
  end

  describe "custom options" do
    let(:options) do
      {
        kubeconfig_path: "/custom/path/config",
        cluster_endpoint: "https://custom.cluster.com:6443",
        namespace: "production",
        timeout: 60,
      }
    end

    before do
      File.stubs(:exist?).with("/custom/path/config").returns(true)
      File.stubs(:readable?).with("/custom/path/config").returns(true)
    end

    it "uses custom kubeconfig path" do
      _(transport.options[:kubeconfig_path]).must_equal "/custom/path/config"
    end

    it "uses custom cluster endpoint" do
      _(transport.options[:cluster_endpoint]).must_equal "https://custom.cluster.com:6443"
    end

    it "uses custom namespace" do
      _(transport.options[:namespace]).must_equal "production"
    end

    it "uses custom timeout" do
      _(transport.options[:timeout]).must_equal 60
    end
  end

  describe "connection" do
    let(:connection) { transport.connection }

    it "returns a kubernetes connection" do
      _(connection).must_be_kind_of Train::Transports::Kubernetes::Connection
    end

    it "caches the connection" do
      _(transport.connection).must_equal transport.connection
    end

    it "has correct platform" do
      platform = connection.platform
      _(platform.name).must_equal "kubernetes"
      _(platform.family_hierarchy).must_include "api"
    end

    it "has correct uri" do
      _(connection.uri).must_include "kubernetes://"
    end

    it "has unique identifier" do
      _(connection.unique_identifier).must_include "kubernetes:"
    end
  end

  describe "validation errors" do
    describe "when kubeconfig does not exist" do
      before do
        # Override the default mock to simulate file not existing
        File.unstub(:exist?)
        File.stubs(:exist?).returns(false)
      end

      it "raises TransportError" do
        error = _ { transport.connection }.must_raise Train::TransportError
        _(error.message).must_include "Kubeconfig file not found"
      end
    end

    describe "when kubeconfig is not readable" do
      before do
        # Override the default mock to simulate file not readable
        File.unstub(:readable?)
        File.stubs(:readable?).returns(false)
      end

      it "raises TransportError" do
        error = _ { transport.connection }.must_raise Train::TransportError
        _(error.message).must_include "Kubeconfig file not readable"
      end
    end

    describe "when kubectl is not available" do
      before do
        # Override the default mock to simulate kubectl not available
        Open3.unstub(:capture3)
        Open3.stubs(:capture3).with("kubectl", "version", "--client", "--output=json").returns(
          ["", "kubectl: command not found", stub(success?: false)]
        )
      end

      it "raises TransportError" do
        error = _ { transport.connection }.must_raise Train::TransportError
        _(error.message).must_include "kubectl command not found"
      end
    end

    describe "when cluster connection fails" do
      before do
        # Override the default mock to simulate cluster connection failure
        Open3.unstub(:popen3)
        Open3.stubs(:popen3).returns([nil, mock_io(""), mock_io("Unable to connect to the server"), mock_wait_thread(true, 1)])
      end

      it "raises TransportError" do
        error = _ { transport.connection }.must_raise Train::TransportError
        _(error.message).must_include "Unable to connect to cluster"
      end
    end
  end

  describe "command execution" do
    let(:connection) { transport.connection }

    before do
      connection.stubs(:execute_kubectl_command).returns(
        Train::Extras::CommandResult.new("kubectl output", "", 0)
      )
    end

    it "executes kubectl commands" do
      result = connection.run_command("kubectl get pods")
      _(result.stdout).must_equal "kubectl output"
      _(result.stderr).must_equal ""
      _(result.exit_status).must_equal 0
    end

    it "rejects non-kubectl commands" do
      result = connection.run_command("echo hello")
      _(result.stdout).must_equal ""
      _(result.stderr).must_include "Kubernetes transport only supports kubectl operations"
      _(result.exit_status).must_equal 1
    end

    it "handles command timeouts" do
      connection.stubs(:execute_kubectl_command).raises(Train::CommandTimeoutReached.new("timeout"))

      _ { connection.run_command("kubectl get pods") }.must_raise Train::CommandTimeoutReached
    end
  end

  describe "file operations" do
    let(:connection) { transport.connection }
    let(:configmap_yaml) do
      {
        "apiVersion" => "v1",
        "kind" => "ConfigMap",
        "metadata" => { "name" => "test-config", "namespace" => "default" },
        "data" => { "database.yml" => "host: localhost\nport: 5432" },
      }.to_yaml
    end

    let(:secret_yaml) do
      {
        "apiVersion" => "v1",
        "kind" => "Secret",
        "metadata" => { "name" => "test-secret", "namespace" => "default" },
        "data" => { "password" => Base64.encode64("secret123") },
      }.to_yaml
    end

    describe "ConfigMap access" do
      before do
        # Mock existence check
        connection.stubs(:execute_kubectl_command).with do |cmd|
          cmd.include?("get") && cmd.include?("configmap") && cmd.include?("test-config")
        end.returns(Train::Extras::CommandResult.new("configmap exists", "", 0))

        # Mock content retrieval
        connection.stubs(:execute_kubectl_command).with do |cmd|
          cmd.include?("get") && cmd.include?("configmap") && cmd.include?("-o") && cmd.include?("yaml")
        end.returns(Train::Extras::CommandResult.new(configmap_yaml, "", 0))
      end

      it "checks if configmap exists" do
        file = connection.file("/configmap/default/test-config/database.yml")
        _(file.exist?).must_equal true
      end

      it "retrieves configmap content" do
        file = connection.file("/configmap/default/test-config/database.yml")
        _(file.content).must_equal "host: localhost\nport: 5432"
      end

      it "has correct metadata" do
        file = connection.file("/configmap/default/test-config/database.yml")
        _(file.size).must_equal 26
        _(file.type).must_equal :file
        _(file.owner).must_equal "kubernetes"
        _(file.group).must_equal "kubernetes"
        _(file.mode).must_equal 0644
      end
    end

    describe "Secret access" do
      before do
        # Mock existence check
        connection.stubs(:execute_kubectl_command).with do |cmd|
          cmd.include?("get") && cmd.include?("secret") && cmd.include?("test-secret")
        end.returns(Train::Extras::CommandResult.new("secret exists", "", 0))

        # Mock content retrieval
        connection.stubs(:execute_kubectl_command).with do |cmd|
          cmd.include?("get") && cmd.include?("secret") && cmd.include?("-o") && cmd.include?("yaml")
        end.returns(Train::Extras::CommandResult.new(secret_yaml, "", 0))
      end

      it "checks if secret exists" do
        file = connection.file("/secret/default/test-secret/password")
        _(file.exist?).must_equal true
      end

      it "retrieves and decodes secret content" do
        file = connection.file("/secret/default/test-secret/password")
        _(file.content).must_equal "secret123"
      end
    end

    describe "Pod logs access" do
      before do
        # Mock pod existence check
        connection.stubs(:execute_kubectl_command).with do |cmd|
          cmd.include?("get") && cmd.include?("pod") && cmd.include?("test-pod")
        end.returns(Train::Extras::CommandResult.new("pod exists", "", 0))

        # Mock log retrieval
        connection.stubs(:execute_kubectl_command).with do |cmd|
          cmd.include?("logs") && cmd.include?("test-pod")
        end.returns(Train::Extras::CommandResult.new("Pod log output\nLine 2", "", 0))
      end

      it "checks if pod exists" do
        file = connection.file("/logs/default/test-pod")
        _(file.exist?).must_equal true
      end

      it "retrieves pod logs" do
        file = connection.file("/logs/default/test-pod")
        _(file.content).must_equal "Pod log output\nLine 2"
      end
    end

    describe "non-existent resources" do
      before do
        connection.stubs(:execute_kubectl_command).returns(
          Train::Extras::CommandResult.new("", "Error from server (NotFound)", 1)
        )
      end

      it "returns false for non-existent resources" do
        file = connection.file("/configmap/default/missing/key")
        _(file.exist?).must_equal false
      end

      it "returns nil content for non-existent resources" do
        file = connection.file("/configmap/default/missing/key")
        _(file.content).must_be_nil
      end
    end

    describe "invalid paths" do
      it "returns false for invalid resource types" do
        file = connection.file("/invalid/default/name")
        _(file.exist?).must_equal false
      end

      it "returns nil content for invalid paths" do
        file = connection.file("/invalid/default/name")
        _(file.content).must_be_nil
      end
    end
  end

  describe "kubectl command building" do
    let(:connection) { transport.connection }

    it "builds basic kubectl command" do
      cmd = connection.send(:build_kubectl_command, %w{get pods})
      _(cmd).must_include "kubectl"
      _(cmd).must_include "get"
      _(cmd).must_include "pods"
    end

    it "adds namespace when not default" do
      connection.instance_variable_set(:@namespace, "production")
      cmd = connection.send(:build_kubectl_command, %w{get pods})
      _(cmd).must_include "--namespace"
      _(cmd).must_include "production"
    end

    it "uses cluster endpoint when provided" do
      connection.instance_variable_set(:@cluster_endpoint, "https://cluster.example.com:6443")
      cmd = connection.send(:build_kubectl_command, %w{get pods})
      _(cmd).must_include "--server"
      _(cmd).must_include "https://cluster.example.com:6443"
    end
  end

  describe "error handling" do
    let(:connection) do
      # Create a mock connection without going through the real connection process
      conn = Train::Transports::Kubernetes::Connection.new({})
      conn.instance_variable_set(:@namespace, "default")
      conn.instance_variable_set(:@kubeconfig, "/tmp/fake_kubeconfig")
      conn.instance_variable_set(:@timeout, 30)
      conn
    end

    it "handles YAML parsing errors gracefully" do
      YAML.stubs(:load_file).raises(StandardError.new("Invalid YAML"))

      endpoint = connection.send(:extract_cluster_endpoint)
      _(endpoint).must_be_nil
    end

    it "handles missing kubeconfig sections" do
      YAML.stubs(:load_file).returns({})

      endpoint = connection.send(:extract_cluster_endpoint)
      _(endpoint).must_be_nil
    end

    it "handles command execution errors" do
      Open3.stubs(:popen3).raises(StandardError.new("Command failed"))

      result = connection.send(:execute_kubectl_command, %w{kubectl get pods})
      _(result.stdout).must_equal ""
      _(result.stderr).must_include "Command failed"
      _(result.exit_status).must_equal 1
    end
  end

  describe "security" do
    let(:connection) do
      # Create a mock connection without going through the real connection process
      conn = Train::Transports::Kubernetes::Connection.new({})
      conn.instance_variable_set(:@namespace, "default")
      conn.instance_variable_set(:@kubeconfig, "/tmp/fake_kubeconfig")
      conn.instance_variable_set(:@timeout, 30)
      conn
    end

    it "does not expose credentials in error messages" do
      Open3.stubs(:popen3).returns([nil, mock_io(""), mock_io("authentication failed"), mock_wait_thread(true, 1)])

      error = _ { connection.send(:test_connection) }.must_raise Train::TransportError
      _(error.message).wont_include "token"
      _(error.message).wont_include "password"
    end
  end

  describe "platform detection" do
    let(:connection) { transport.connection }

    it "identifies as kubernetes platform" do
      platform = connection.platform
      _(platform.name).must_equal "kubernetes"
      _(platform[:name]).must_equal "kubernetes"
      _(platform.to_hash[:family]).must_include "api"
    end

    it "includes version information" do
      platform = connection.platform
      _(platform[:release]).wont_be_nil
    end
  end

  describe "close connection" do
    let(:connection) { transport.connection }

    it "closes without error" do
      _(connection.close).must_be_nil
    end
  end
end
