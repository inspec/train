# encoding: utf-8

require 'train/plugins'
require 'ms_rest_azure'
require 'azure_mgmt_resources'
require 'inifile'

module Train::Transports
  class Azure < Train.plugin(1)
    name 'azure'
    option :tenant_id, default: ENV['AZURE_TENANT_ID']
    option :client_id, default: ENV['AZURE_CLIENT_ID']
    option :client_secret, default: ENV['AZURE_CLIENT_SECRET']
    option :subscription_id, default: ENV['AZURE_SUBSCRIPTION_ID']

    # This can provide the client id and secret
    option :credentials_file, default: ENV['AZURE_CRED_FILE']

    def connection(_ = nil)
      @connection ||= Connection.new(@options)
    end

    class Connection < BaseConnection
      def initialize(options)
        # Override for any cli options
        # azure://subscription_id
        options[:subscription_id] = options[:host] || options[:subscription_id]
        super(options)

        @cache_enabled[:api_call] = true
        @cache[:api_call] = {}

        if @options[:client_secret].nil? && @options[:client_id].nil?
          parse_credentials_file
        end
        connect
      end

      def platform
        direct_platform('azure')
      end

      def azure_client(klass = ::Azure::Resources::Profiles::Latest::Mgmt::Client)
        return klass.new(@credentials) unless cache_enabled?(:api_call)

        @cache[:api_call][klass.to_s.to_sym] ||= klass.new(@credentials)
      end

      def connect
        provider = ::MsRestAzure::ApplicationTokenProvider.new(
          @options[:tenant_id],
          @options[:client_id],
          @options[:client_secret],
        )

        @credentials = {
          credentials: ::MsRest::TokenCredentials.new(provider),
          subscription_id: @options[:subscription_id],
          tenant_id: @options[:tenant_id],
          client_id: @options[:client_id],
          client_secret: @options[:client_secret],
        }
      end

      def uri
        "azure://#{@options[:subscription_id]}"
      end

      private

      def parse_credentials_file # rubocop:disable Metrics/AbcSize
        # If an INSPEC_AZURE_CREDS environment has been specified set the
        # the credentials file to that, otherwise set the one in home
        azure_creds_file = @options[:credentials_file]
        azure_creds_file = File.join(Dir.home, '.azure', 'credentials') if azure_creds_file.nil?
        return unless File.readable?(azure_creds_file)

        credentials = IniFile.load(File.expand_path(azure_creds_file))
        if @options[:subscription_id]
          id = @options[:subscription_id]
        elsif !ENV['AZURE_SUBSCRIPTION_NUMBER'].nil?
          subscription_number = ENV['AZURE_SUBSCRIPTION_NUMBER'].to_i

          # Check that the specified index is not greater than the number of subscriptions
          if subscription_number > credentials.sections.length
            raise format(
              'Your credentials file only contains %s subscriptions.  You specified number %s.',
              @credentials.sections.length,
              subscription_number,
            )
          end
          id = credentials.sections[subscription_number - 1]
        else
          raise 'Multiple credentials detected, please set the AZURE_SUBSCRIPTION_ID environment variable.' if credentials.sections.count > 1
          id = credentials.sections[0]
        end

        raise "No credentials found for subscription number #{id}" if credentials.sections.empty? || credentials[id].empty?
        @options[:subscription_id] = id
        @options[:tenant_id] = credentials[id]['tenant_id']
        @options[:client_id] = credentials[id]['client_id']
        @options[:client_secret] = credentials[id]['client_secret']
      end
    end
  end
end
