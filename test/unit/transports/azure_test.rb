require "helper"

# Required because this test file acesses classes under Azure::
require "azure_mgmt_resources2"
require "azure_graph_rbac2"
require "azure_mgmt_key_vault2"

describe "azure transport" do
  def transport(options = nil)
    ENV["AZURE_TENANT_ID"] = "test_tenant_id"
    ENV["AZURE_CLIENT_ID"] = "test_client_id"
    ENV["AZURE_CLIENT_SECRET"] = "test_client_secret"
    ENV["AZURE_SUBSCRIPTION_ID"] = "test_subscription_id"

    # need to require this at here as it captures the envs on load
    require "train/transports/azure"
    Train::Transports::Azure.new(options)
  end
  let(:connection) { transport.connection }
  let(:options) { connection.instance_variable_get(:@options) }
  let(:cache) { connection.instance_variable_get(:@cache) }
  let(:credentials) { connection.instance_variable_get(:@credentials) }

  describe "options" do
    it "defaults to env options" do
      _(options[:tenant_id]).must_equal "test_tenant_id"
      _(options[:client_id]).must_equal "test_client_id"
      _(options[:client_secret]).must_equal "test_client_secret"
      _(options[:subscription_id]).must_equal "test_subscription_id"
    end

    it "allows for options override" do
      transport = transport(subscription_id: "102", client_id: "717")
      options = transport.connection.instance_variable_get(:@options)
      _(options[:tenant_id]).must_equal "test_tenant_id"
      _(options[:client_id]).must_equal "717"
      _(options[:client_secret]).must_equal "test_client_secret"
      _(options[:subscription_id]).must_equal "102"
    end

    it "allows uri parse override" do
      transport = transport(host: "999")
      options = transport.connection.instance_variable_get(:@options)
      _(options[:tenant_id]).must_equal "test_tenant_id"
      _(options[:subscription_id]).must_equal "999"
    end
  end

  describe "platform" do
    it "returns platform" do
      plat = connection.platform
      _(plat.name).must_equal "azure"
      _(plat.family_hierarchy).must_equal %w{cloud api}
    end
  end

  describe "azure_client" do
    class AzureResource
      attr_reader :hash
      def initialize(hash)
        @hash = hash
      end
    end

    it "can use azure_client with caching" do
      connection.instance_variable_set(:@credentials, {})
      client = connection.azure_client(AzureResource)
      _(client.is_a?(AzureResource)).must_equal true
      _(cache[:api_call].count).must_equal 1
    end

    it "can use azure_client without caching" do
      connection.instance_variable_set(:@credentials, {})
      connection.disable_cache(:api_call)
      client = connection.azure_client(AzureResource)
      _(client.is_a?(AzureResource)).must_equal true
      _(cache[:api_call].count).must_equal 0
    end

    it "can use azure_client default client" do
      management_api_client = Azure::Resources2::Profiles::Latest::Mgmt::Client
      client = connection.azure_client
      _(client.class).must_equal management_api_client
    end

    it "can use azure_client graph client" do
      graph_api_client = Azure::GraphRbac2::Profiles::Latest::Client
      client = connection.azure_client(graph_api_client)
      _(client.class).must_equal graph_api_client
    end

    it "can use azure_client vault client" do
      vault_api_client = ::Azure::KeyVault::Profiles::Latest::Mgmt::Client
      client = connection.azure_client(vault_api_client, vault_name: "Test Vault")
      _(client.class).must_equal vault_api_client
    end

    it "cannot instantiate azure_client vault client without a vault name" do
      vault_api_client = ::Azure::KeyVault2::Profiles::Latest::Mgmt::Client
      assert_raises(Train::UserError) do
        connection.azure_client(vault_api_client)
      end
    end
  end

  describe "connect" do
    it "validate credentials" do
      connection.connect
      token = credentials[:credentials].instance_variable_get(:@token_provider)
      _(token.class).must_equal MsRestAzure2::ApplicationTokenProvider

      _(credentials[:credentials].class).must_equal MsRest2::TokenCredentials
      _(credentials[:tenant_id]).must_equal "test_tenant_id"
      _(credentials[:client_id]).must_equal "test_client_id"
      _(credentials[:client_secret]).must_equal "test_client_secret"
      _(credentials[:subscription_id]).must_equal "test_subscription_id"
    end

    it "validate msi credentials" do
      options[:client_id] = nil
      options[:client_secret] = nil
      Train::Transports::Azure::Connection.any_instance.stubs(:port_open?).returns(true)

      connection.connect
      token = credentials[:credentials].instance_variable_get(:@token_provider)
      _(token.class).must_equal MsRestAzure2::MSITokenProvider

      _(credentials[:credentials].class).must_equal MsRest2::TokenCredentials
      _(credentials[:tenant_id]).must_equal "test_tenant_id"
      _(credentials[:subscription_id]).must_equal "test_subscription_id"
      _(credentials[:client_id]).must_be_nil
      _(credentials[:client_secret]).must_be_nil
      _(options[:msi_port]).must_equal 50342
    end
  end

  describe "unique_identifier" do
    it "returns a subscription id" do
      _(connection.unique_identifier).must_equal "test_subscription_id"
    end

    it "returns a tenant id" do
      options = connection.instance_variable_get(:@options)
      options[:subscription_id] = nil
      _(connection.unique_identifier).must_equal "test_tenant_id"
    end
  end
end
