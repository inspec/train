# encoding: utf-8

require 'train/plugins'
require 'google/apis'
require 'google/apis/cloudresourcemanager_v1'
require 'google/apis/compute_v1'
require 'google/apis/storage_v1'
require 'google/apis/iam_v1'
require 'googleauth'

module Train::Transports
  class Gcp < Train.plugin(1)
    name 'gcp'

    # GCP will look automatically for the below env var for service accounts etc. :
    option :google_application_credentials, required: false, default: ENV['GOOGLE_APPLICATION_CREDENTIALS']
    # see https://cloud.google.com/docs/authentication/production#providing_credentials_to_your_application
    # In the absence of this, the client is expected to have already set up local credentials via:
    #   $ gcloud auth application-default login
    #   $ gcloud config set project <project-name>
    # GCP projects can have default regions / zones set, see:
    # https://cloud.google.com/compute/docs/regions-zones/changing-default-zone-region
    # can also specify project via env var:
    option :google_cloud_project, required: false, default: ENV['GOOGLE_CLOUD_PROJECT']

    def connection(_ = nil)
      @connection ||= Connection.new(@options)
    end

    class Connection < BaseConnection
      def initialize(options)
        super(options)

        # additional GCP platform metadata
        release = Gem.loaded_specs['google-api-client'].version
        @platform_details = { release: "google-api-client-v#{release}" }

        # Initialize the client object cache
        @cache_enabled[:api_call] = true
        @cache[:api_call] = {}

        connect
      end

      def platform
        direct_platform('gcp', @platform_details)
      end

      # Instantiate some named classes for ease of use
      def gcp_compute_client
        gcp_client(Google::Apis::ComputeV1::ComputeService)
      end

      def gcp_iam_client
        gcp_client(Google::Apis::IamV1::IamService)
      end

      def gcp_project_client
        gcp_client(Google::Apis::CloudresourcemanagerV1::CloudResourceManagerService)
      end

      def gcp_storage_client
        gcp_client(Google::Apis::StorageV1::StorageService)
      end

      # Let's allow for other clients too
      def gcp_client(klass)
        return klass.new unless cache_enabled?(:api_call)
        @cache[:api_call][klass.to_s.to_sym] ||= klass.new
      end

      def connect
        ENV['GOOGLE_APPLICATION_CREDENTIALS'] = @options[:google_application_credentials] if @options[:google_application_credentials]
        ENV['GOOGLE_CLOUD_PROJECT'] = @options[:google_cloud_project] if @options[:google_cloud_project]
        # GCP initialization
        scopes = ['https://www.googleapis.com/auth/cloud-platform',
                  'https://www.googleapis.com/auth/compute']
        authorization = Google::Auth.get_application_default(scopes)
        Google::Apis::RequestOptions.default.authorization = authorization
      end

      def uri
        "gcp://#{unique_identifier}"
      end

      def unique_identifier
        # use auth client_id - same to retrieve for any of the clients but use IAM
        gcp_iam_client.request_options.authorization.client_id
      end
    end
  end
end
