# encoding: utf-8
require 'train/plugins'
require 'aws-sdk'

module Train::Transports
  class Aws < Train.plugin(1)
    name 'aws'
    option :region, required: true, default: ENV['AWS_REGION']
    option :access_key_id, default: ENV['AWS_ACCESS_KEY_ID']
    option :secret_access_key, default: ENV['AWS_SECRET_ACCESS_KEY']
    option :session_token, default: ENV['AWS_SESSION_TOKEN']

    # This can provide the access key id and secret access key
    option :profile, default: ENV['AWS_PROFILE']

    def connection(_ = nil)
      @connection ||= Connection.new(@options)
    end

    class Connection < BaseConnection
      def initialize(options)
        # Override for any cli options
        # aws://region/my-profile
        options[:region] = options[:host] || options[:region]
        if options[:path]
          # string the leading / from path
          options[:profile] = options[:path][1..-1]
        end
        super(options)

        @cache_enabled[:api_call] = true
        @cache[:api_call] = {}

        # additional platform details
        release = Gem.loaded_specs['aws-sdk'].version
        @platform_details = { release: "aws-sdk-v#{release}" }

        connect
      end

      def platform
        force_platform!('aws', @platform_details)
      end

      def aws_client(klass)
        return klass.new unless cache_enabled?(:api_call)
        @cache[:api_call][klass.to_s.to_sym] ||= klass.new
      end

      def aws_resource(klass, args)
        klass.new(args)
      end

      def connect
        ENV['AWS_PROFILE'] = @options[:profile] if @options[:profile]
        ENV['AWS_REGION'] = @options[:region] if @options[:region]
      end

      def uri
        "aws://#{@options[:region]}"
      end

      def unique_identifier
        # use aws account id
        client = aws_client(::Aws::STS::Client)
        client.get_caller_identity.account
      end
    end
  end
end
