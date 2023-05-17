require "train/plugins"
require "socket" unless defined?(Socket)
require "timeout" unless defined?(Timeout)
require "train/transports/helpers/azure/file_credentials"

module Train::Transports
  class Azure < Train.plugin(1)
    name "azure"
    option :tenant_id, default: ENV["AZURE_TENANT_ID"]
    option :client_id, default: ENV["AZURE_CLIENT_ID"]
    option :client_secret, default: ENV["AZURE_CLIENT_SECRET"]
    option :subscription_id, default: ENV["AZURE_SUBSCRIPTION_ID"]

    # This can provide the client id and secret
    option :credentials_file, default: ENV["AZURE_CRED_FILE"]

    def connection(_ = nil)
      @connection ||= Connection.new(@options)
    end

    # @note all logic in this class is kept only to be moved later into inspec-azure
    class Connection < BaseConnection
      attr_reader :options

      DEFAULT_FILE = ::File.join(Dir.home, ".azure", "credentials")

      def initialize(options)
        @apis = {}

        # Override for any cli options
        # azure://subscription_id
        options[:subscription_id] = options[:host] || options[:subscription_id]
        super(options)

        @cache_enabled[:api_call] = true
        @cache[:api_call] = {}

        if @options[:client_secret].nil? && @options[:client_id].nil?
          options[:credentials_file] = DEFAULT_FILE if options[:credentials_file].nil?
          @options.merge!(Helpers::Azure::FileCredentials.parse(**@options))
        end
      end

      def platform
        force_platform!("azure", @platform_details)
      end

      # @note klass needs to be overriden to accept resource management class
      def azure_client(klass = nil, opts = {})
        if cache_enabled?(:api_call)
          return @cache[:api_call][klass.to_s.to_sym] unless @cache[:api_call][klass.to_s.to_sym].nil?
        end

        client ||= klass.new(@credentials)
        # Cache if enabled
        @cache[:api_call][klass.to_s.to_sym] ||= client if cache_enabled?(:api_call)

        client
      end

      def uri
        "azure://#{@options[:subscription_id]}"
      end

      def unique_identifier
        options[:subscription_id] || options[:tenant_id]
      end
    end
  end
end
