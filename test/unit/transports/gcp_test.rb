require "helper"
require "train/transports/gcp"

describe "gcp transport" do

  let(:credentials_file) do
    require "tempfile" unless defined?(Tempfile)
    file = Tempfile.new("application_default_credentials.json")
    info = <<~INFO
      {
        "client_id": "asdfasf-asdfasdf.apps.googleusercontent.com",
        "client_secret": "d-asdfasdf",
        "refresh_token": "1/adsfasdf-lCkju3-yQmjr20xVZonrfkE48L",
        "type": "authorized_user"
      }
    INFO
    file.write(info)
    file.close
    file
  end

  let(:credentials_file_override) do
    require "tempfile" unless defined?(Tempfile)
    file = Tempfile.new("application_default_credentials.json")
    info = <<~INFO
      {
        "client_id": "asdfasf-asdfasdf.apps.googleusercontent.com",
        "client_secret": "d-asdfasdf",
        "refresh_token": "1/adsfasdf-lCkju3-yQmjr20xVZonrfkE48L",
        "type": "authorized_user"
      }
    INFO
    file.write(info)
    file.close
    file
  end

  def transport(options = nil)
    ENV["GOOGLE_APPLICATION_CREDENTIALS"] = credentials_file.path
    ENV["GOOGLE_CLOUD_PROJECT"] = "test_project"
    Train::Transports::Gcp.new(options)
  end

  let(:connection) { transport.connection }
  let(:options) { connection.instance_variable_get(:@options) }
  let(:cache) { connection.instance_variable_get(:@cache) }

  describe "options" do
    it "defaults to env options" do
      options[:google_application_credentials] = credentials_file.path
      _(options[:google_cloud_project]).must_equal "test_project"
    end
  end

  it "allows for options override" do
    transport = transport(google_application_credentials: credentials_file_override.path, google_cloud_project: "override_project")
    options = transport.connection.instance_variable_get(:@options)
    _(options[:google_application_credentials]).must_equal credentials_file_override.path
    _(options[:google_cloud_project]).must_equal "override_project"
  end

  describe "platform" do
    it "returns platform" do
      platform = connection.platform
      _(platform.name).must_equal "gcp"
      _(platform.family_hierarchy).must_equal %w{cloud api}
    end
  end

  describe "gcp_client" do
    it "test gcp_client with caching" do
      client = connection.gcp_client(Object)
      _(client.is_a?(Object)).must_equal true
      _(cache[:api_call].count).must_equal 1
    end

    it "test gcp_client without caching" do
      connection.disable_cache(:api_call)
      client = connection.gcp_client(Object)
      _(client.is_a?(Object)).must_equal true
      _(cache[:api_call].count).must_equal 0
    end
  end

  describe "gcp_compute_client" do
    it "test gcp_compute_client with caching" do
      client = connection.gcp_compute_client
      _(client.is_a?(Google::Apis::ComputeV1::ComputeService)).must_equal true
      _(cache[:api_call].count).must_equal 1
    end

    it "test gcp_client without caching" do
      connection.disable_cache(:api_call)
      client = connection.gcp_compute_client
      _(client.is_a?(Google::Apis::ComputeV1::ComputeService)).must_equal true
      _(cache[:api_call].count).must_equal 0
    end

    it "test gcp_compute_client application name" do
      client = connection.gcp_compute_client
      _(client.is_a?(Google::Apis::ComputeV1::ComputeService)).must_equal true
      _(client.client_options.application_name).must_equal "chef-inspec-train"
    end

    it "test gcp_compute_client application version" do
      client = connection.gcp_compute_client
      _(client.is_a?(Google::Apis::ComputeV1::ComputeService)).must_equal true
      _(client.client_options.application_version).must_equal Train::VERSION
    end
  end

  describe "gcp_iam_client" do
    it "test gcp_iam_client with caching" do
      client = connection.gcp_iam_client
      _(client.is_a?(Google::Apis::IamV1::IamService)).must_equal true
      _(cache[:api_call].count).must_equal 1
    end

    it "test gcp_iam_client without caching" do
      connection.disable_cache(:api_call)
      client = connection.gcp_iam_client
      _(client.is_a?(Google::Apis::IamV1::IamService)).must_equal true
      _(cache[:api_call].count).must_equal 0
    end

    it "test gcp_iam_client application name" do
      client = connection.gcp_iam_client
      _(client.is_a?(Google::Apis::IamV1::IamService)).must_equal true
      _(client.client_options.application_name).must_equal "chef-inspec-train"
    end

    it "test gcp_iam_client application version" do
      client = connection.gcp_iam_client
      _(client.is_a?(Google::Apis::IamV1::IamService)).must_equal true
      _(client.client_options.application_version).must_equal Train::VERSION
    end
  end

  describe "gcp_project_client" do
    it "test gcp_project_client with caching" do
      client = connection.gcp_project_client
      _(client.is_a?(Google::Apis::CloudresourcemanagerV1::CloudResourceManagerService)).must_equal true
      _(cache[:api_call].count).must_equal 1
    end

    it "test gcp_project_client without caching" do
      connection.disable_cache(:api_call)
      client = connection.gcp_project_client
      _(client.is_a?(Google::Apis::CloudresourcemanagerV1::CloudResourceManagerService)).must_equal true
      _(cache[:api_call].count).must_equal 0
    end

    it "test gcp_project_client application name" do
      client = connection.gcp_project_client
      _(client.is_a?(Google::Apis::CloudresourcemanagerV1::CloudResourceManagerService)).must_equal true
      _(client.client_options.application_name).must_equal "chef-inspec-train"
    end

    it "test gcp_project_client application version" do
      client = connection.gcp_project_client
      _(client.is_a?(Google::Apis::CloudresourcemanagerV1::CloudResourceManagerService)).must_equal true
      _(client.client_options.application_version).must_equal Train::VERSION
    end
  end

  describe "gcp_storage_client" do
    it "test gcp_storage_client with caching" do
      client = connection.gcp_storage_client
      _(client.is_a?(Google::Apis::StorageV1::StorageService)).must_equal true
      _(cache[:api_call].count).must_equal 1
    end

    it "test gcp_storage_client without caching" do
      connection.disable_cache(:api_call)
      client = connection.gcp_storage_client
      _(client.is_a?(Google::Apis::StorageV1::StorageService)).must_equal true
      _(cache[:api_call].count).must_equal 0
    end

    it "test gcp_storage_client application name" do
      client = connection.gcp_storage_client
      _(client.is_a?(Google::Apis::StorageV1::StorageService)).must_equal true
      _(client.client_options.application_name).must_equal "chef-inspec-train"
    end

    it "test gcp_storage_client application version" do
      client = connection.gcp_storage_client
      _(client.is_a?(Google::Apis::StorageV1::StorageService)).must_equal true
      _(client.client_options.application_version).must_equal Train::VERSION
    end
  end

  describe "gcp_admin_client" do
    it "test gcp_admin_client with caching" do
      client = connection.gcp_admin_client
      _(client.is_a?(Google::Apis::AdminDirectoryV1::DirectoryService)).must_equal true
      _(cache[:api_call].count).must_equal 1
    end

    it "test gcp_admin_client without caching" do
      connection.disable_cache(:api_call)
      client = connection.gcp_admin_client
      _(client.is_a?(Google::Apis::AdminDirectoryV1::DirectoryService)).must_equal true
      _(cache[:api_call].count).must_equal 0
    end

    it "test gcp_admin_client application name" do
      client = connection.gcp_admin_client
      _(client.is_a?(Google::Apis::AdminDirectoryV1::DirectoryService)).must_equal true
      _(client.client_options.application_name).must_equal "chef-inspec-train"
    end

    it "test gcp_admin_client application version" do
      client = connection.gcp_admin_client
      _(client.is_a?(Google::Apis::AdminDirectoryV1::DirectoryService)).must_equal true
      _(client.client_options.application_version).must_equal Train::VERSION
    end
  end

  # test options override of env vars in connect
  describe "connect" do
    let(:creds) do
      require "tempfile" unless defined?(Tempfile)
      file = Tempfile.new("creds")
      info = <<~INFO
        {
          "client_id": "asdfasf-asdfasdf.apps.googleusercontent.com",
          "client_secret": "d-asdfasdf",
          "refresh_token": "1/adsfasdf-lCkju3-yQmjr20xVZonrfkE48L",
          "type": "authorized_user"
        }
      INFO
      file.write(info)
      file.close
      file
    end
    it "validate gcp connection with credentials" do
      options[:google_application_credentials] = creds.path
      connection.connect
      _(ENV["GOOGLE_APPLICATION_CREDENTIALS"]).must_equal creds.path
    end
    it "validate gcp connection with project" do
      options[:google_cloud_project] = "project"
      connection.connect
      _(ENV["GOOGLE_CLOUD_PROJECT"]).must_equal "project"
    end
  end

  describe "unique_identifier" do
    it "test connection unique identifier" do
      client = connection
      _(client.unique_identifier).must_equal "asdfasf-asdfasdf.apps.googleusercontent.com"
    end
  end

  describe "uri" do
    it "test uri" do
      client = connection
      _(client.uri).must_equal "gcp://asdfasf-asdfasdf.apps.googleusercontent.com"
    end
  end
end
