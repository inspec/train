# encoding: utf-8

require 'helper'

describe 'aws transport' do
  def transport(options = nil)
    ENV['AWS_REGION'] = 'test_region'
    ENV['AWS_ACCESS_KEY_ID'] = 'test_key_id'
    ENV['AWS_SECRET_ACCESS_KEY'] = 'test_access_key'
    ENV['AWS_SESSION_TOKEN'] = 'test_session_token'

    # need to require this at here as it captures the envs on load
    require 'train/transports/aws'
    Train::Transports::Aws.new(options)
  end
  let(:connection) { transport.connection }
  let(:options) { connection.instance_variable_get(:@options) }
  let(:cache) { connection.instance_variable_get(:@cache) }

  describe 'options' do
    it 'defaults to env options' do
      options[:region].must_equal 'test_region'
      options[:access_key_id].must_equal 'test_key_id'
      options[:secret_access_key].must_equal 'test_access_key'
      options[:session_token].must_equal 'test_session_token'
    end

    it 'test options override' do
      transport = transport(region: 'us-east-2', access_key_id: '8')
      options = transport.connection.instance_variable_get(:@options)
      options[:region].must_equal 'us-east-2'
      options[:access_key_id].must_equal '8'
      options[:secret_access_key].must_equal 'test_access_key'
      options[:session_token].must_equal 'test_session_token'
    end

    it 'test url parse override' do
      transport = transport(host: 'us-east-2')
      options = transport.connection.instance_variable_get(:@options)
      options[:region].must_equal 'us-east-2'
      options[:session_token].must_equal 'test_session_token'
    end
  end

  describe 'platform' do
    it 'returns platform' do
      plat = connection.platform
      plat.name.must_equal 'aws'
      plat.family_hierarchy.must_equal ['cloud', 'api']
    end
  end

  describe 'aws_client' do
    it 'test aws_client with caching' do
      client = connection.aws_client(Object)
      client.is_a?(Object).must_equal true
      cache[:api_call].count.must_equal 1
    end

    it 'test aws_client without caching' do
      connection.disable_cache(:api_call)
      client = connection.aws_client(Object)
      client.is_a?(Object).must_equal true
      cache[:api_call].count.must_equal 0
    end
  end

  describe 'aws_resource' do
    class AwsResource
      attr_reader :hash
      def initialize(hash)
        @hash = hash
      end
    end

    it 'test aws_resource with arguments' do
      hash = { user: 1, name: 'test_user' }
      resource = connection.aws_resource(AwsResource, hash)
      resource.hash.must_equal hash
      cache[:api_call].count.must_equal 0
    end
  end

  describe 'connect' do
    it 'validate aws connection with profile' do
      options[:profile] = 'xyz'
      ENV['AWS_PROFILE'].must_be_nil
      connection.connect
      ENV['AWS_PROFILE'].must_equal 'xyz'
    end

    it 'validate aws connection with region' do
      options[:region] = 'xyz'
      ENV['AWS_REGION'].must_equal 'test_region'
      connection.connect
      ENV['AWS_REGION'].must_equal 'xyz'
    end
  end

  describe 'unique_identifier' do
    class AwsArn
      def arn
        'arn:aws:iam::158551926027:user/test-fixture-maker'
      end
    end

    class AwsUser
      def user
        AwsArn.new
      end
    end

    class AwsClient
      def get_user
        AwsUser.new
      end
    end
    it 'returns an account id' do
      connection.stubs(:aws_client).returns(AwsClient.new)
      connection.unique_identifier.must_equal '158551926027'
    end
  end
end
