# encoding: utf-8

require 'helper'

describe 'azure transport' do
  def transport(options = nil)
    ENV['AZURE_TENANT_ID'] = 'test_tenant_id'
    ENV['AZURE_CLIENT_ID'] = 'test_client_id'
    ENV['AZURE_CLIENT_SECRET'] = 'test_client_secret'
    ENV['AZURE_SUBSCRIPTION_ID'] = 'test_subscription_id'

    # need to require this at here as it captures the envs on load
    require 'train/transports/azure'
    Train::Transports::Azure.new(options)
  end
  let(:connection) { transport.connection }
  let(:options) { connection.instance_variable_get(:@options) }
  let(:cache) { connection.instance_variable_get(:@cache) }
  let(:credentials) { connection.instance_variable_get(:@credentials) }

  describe 'options' do
    it 'defaults to env options' do
      options[:tenant_id].must_equal 'test_tenant_id'
      options[:client_id].must_equal 'test_client_id'
      options[:client_secret].must_equal 'test_client_secret'
      options[:subscription_id].must_equal 'test_subscription_id'
    end

    it 'allows for options override' do
      transport = transport(subscription_id: '102', client_id: '717')
      options = transport.connection.instance_variable_get(:@options)
      options[:tenant_id].must_equal 'test_tenant_id'
      options[:client_id].must_equal '717'
      options[:client_secret].must_equal 'test_client_secret'
      options[:subscription_id].must_equal '102'
    end

    it 'allows uri parse override' do
      transport = transport(host: '999')
      options = transport.connection.instance_variable_get(:@options)
      options[:tenant_id].must_equal 'test_tenant_id'
      options[:subscription_id].must_equal '999'
    end
  end

  describe 'platform' do
    it 'returns platform' do
      plat = connection.platform
      plat.name.must_equal 'azure'
      plat.family_hierarchy.must_equal ['cloud', 'api']
    end
  end

  describe 'azure_client' do
    class AzureResource
      attr_reader :hash
      def initialize(hash)
        @hash = hash
      end
    end

    it 'can use azure_client with caching' do
      connection.instance_variable_set(:@credentials, {})
      client = connection.azure_client(AzureResource)
      client.is_a?(AzureResource).must_equal true
      cache[:api_call].count.must_equal 1
    end

    it 'can use azure_client without caching' do
      connection.instance_variable_set(:@credentials, {})
      connection.disable_cache(:api_call)
      client = connection.azure_client(AzureResource)
      client.is_a?(AzureResource).must_equal true
      cache[:api_call].count.must_equal 0
    end

    it 'can use azure_client default client' do
      MANAGEMENT_API_CLIENT = Azure::Resources::Profiles::Latest::Mgmt::Client
      client = connection.azure_client
      client.class.must_equal MANAGEMENT_API_CLIENT
    end

    it 'can use azure_client graph client' do
      GRAPH_API_CLIENT      = Azure::GraphRbac::Profiles::Latest::Client
      client = connection.azure_client(GRAPH_API_CLIENT)
      client.class.must_equal GRAPH_API_CLIENT
    end
  end

  describe 'connect' do
    it 'validate credentials' do
      connection.connect
      token = credentials[:credentials].instance_variable_get(:@token_provider)
      token.class.must_equal MsRestAzure::ApplicationTokenProvider

      credentials[:credentials].class.must_equal MsRest::TokenCredentials
      credentials[:tenant_id].must_equal 'test_tenant_id'
      credentials[:client_id].must_equal 'test_client_id'
      credentials[:client_secret].must_equal 'test_client_secret'
      credentials[:subscription_id].must_equal 'test_subscription_id'
    end

    it 'validate msi credentials' do
      options[:client_id] = nil
      options[:client_secret] = nil
      Train::Transports::Azure::Connection.any_instance.stubs(:port_open?).returns(true)

      connection.connect
      token = credentials[:credentials].instance_variable_get(:@token_provider)
      token.class.must_equal MsRestAzure::MSITokenProvider

      credentials[:credentials].class.must_equal MsRest::TokenCredentials
      credentials[:tenant_id].must_equal 'test_tenant_id'
      credentials[:subscription_id].must_equal 'test_subscription_id'
      credentials[:client_id].must_be_nil
      credentials[:client_secret].must_be_nil
      options[:msi_port].must_equal 50342
    end
  end

  describe 'unique_identifier' do
    it 'returns a subscription id' do
      connection.unique_identifier.must_equal 'test_subscription_id'
    end

    it 'returns a tenant id' do
      options = connection.instance_variable_get(:@options)
      options[:subscription_id] = nil
      connection.unique_identifier.must_equal 'test_tenant_id'
    end
  end

  describe 'parse_credentials_file' do
    let(:cred_file) do
      require 'tempfile'
      file = Tempfile.new('cred_file')
      info = <<-INFO
        [my_subscription_id]
        client_id = "my_client_id"
        client_secret = "my_client_secret"
        tenant_id = "my_tenant_id"

        [my_subscription_id2]
        client_id = "my_client_id2"
        client_secret = "my_client_secret2"
        tenant_id = "my_tenant_id2"
      INFO
      file.write(info)
      file.close
      file
    end

    it 'validate credentials from file' do
      options[:credentials_file] = cred_file.path
      options[:subscription_id] = 'my_subscription_id'
      connection.send(:parse_credentials_file)

      options[:tenant_id].must_equal 'my_tenant_id'
      options[:client_id].must_equal 'my_client_id'
      options[:client_secret].must_equal 'my_client_secret'
      options[:subscription_id].must_equal 'my_subscription_id'
    end

    it 'validate credentials from file subscription override' do
      options[:credentials_file] = cred_file.path
      options[:subscription_id] = 'my_subscription_id2'
      connection.send(:parse_credentials_file)

      options[:tenant_id].must_equal 'my_tenant_id2'
      options[:client_id].must_equal 'my_client_id2'
      options[:client_secret].must_equal 'my_client_secret2'
      options[:subscription_id].must_equal 'my_subscription_id2'
    end

    it 'validate credentials from file subscription index' do
      options[:credentials_file] = cred_file.path
      options[:subscription_id] = nil
      ENV['AZURE_SUBSCRIPTION_NUMBER'] = '2'
      connection.send(:parse_credentials_file)

      options[:tenant_id].must_equal 'my_tenant_id2'
      options[:client_id].must_equal 'my_client_id2'
      options[:client_secret].must_equal 'my_client_secret2'
      options[:subscription_id].must_equal 'my_subscription_id2'
    end
  end
end
