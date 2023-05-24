require "helper"

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
