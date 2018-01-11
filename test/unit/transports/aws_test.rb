# encoding: utf-8

# envs have to be set before we start up the testing
ENV['AWS_REGION'] = 'test_region'
ENV['AWS_ACCESS_KEY_ID'] = 'test_key_id'
ENV['AWS_SECRET_ACCESS_KEY'] = 'test_access_key'
ENV['AWS_SESSION_TOKEN'] = 'test_session_token'

require 'helper'
require 'train/transports/aws'

describe 'aws transport' do
  def transport(options = nil)
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
    it 'validate aws connection config' do
      options[:profile] = nil
      creds = connection.connect
      creds[:credentials].access_key_id.must_equal 'test_key_id'
      creds[:credentials].secret_access_key.must_equal 'test_access_key'
      creds[:credentials].session_token.must_equal 'test_session_token'
      creds[:region].must_equal 'test_region'
    end
  end
end
