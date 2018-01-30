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

        connect
      end

      def platform
        direct_platform('aws')
      end

      def aws_client(klass)
        return klass.new unless cache_enabled?(:api_call)
        @cache[:api_call][klass.to_s.to_sym] ||= klass.new
      end

      def aws_resource(klass, args)
        klass.new(args)
      end

      def connect
        if @options[:profile]
          creds = ::Aws::SharedCredentials.new(profile_name: @options[:profile])
        else
          creds = ::Aws::Credentials.new(
            @options[:access_key_id],
            @options[:secret_access_key],
            @options[:session_token],
          )
        end

        opts = {
          region: @options[:region],
          credentials: creds,
        }
        ::Aws.config.update(opts)
      end

      def uri
        "aws://#{@options[:region]}"
      end
    end
  end
end
