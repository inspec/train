# encoding: utf-8
require 'helper'

describe 'train cache connection' do
  let(:cls) { Train::Plugins::Transport::BaseConnection }
  let(:connection) { cls.new({}) }
  let(:cache_connection) { Train::Plugins::Transport::CacheConnection.new(connection) }

  describe 'create cache connection' do
    it 'return new cache connection' do
      cache_connection.must_be_kind_of Train::Plugins::Transport::CacheConnection
      cache_connection.respond_to?(:run_command).must_equal true
      cache_connection.respond_to?(:file).must_equal true
    end

    it 'default connection cache settings' do
      cacher = connection.instance_variable_get(:@cacher)
      cacher.cache_enabled[:file].must_equal true
      cacher.cache_enabled[:command].must_equal false
    end
  end

  describe 'disable/enable caching' do
    it 'enable file cache' do
      connection.enable_cache(:file)
      cache_connection.cache_enabled[:file].must_equal true
    end
  end

  describe 'clear cache' do
    it 'clear file cache' do
      cache = cache_connection.instance_variable_get(:@cache)
      cache[:file]['/tmp'] = 'test'
      cache_connection.clear_cache(:file)
      cache = cache_connection.instance_variable_get(:@cache)
      cache[:file].must_equal({})
    end
  end

  describe 'load file' do
    it 'load file with caching' do
      connection.expects(:file_via_connection).once.returns('test_file')
      cache_connection.file('/tmp/test').must_equal('test_file')
      cache_connection.file('/tmp/test').must_equal('test_file')
      assert = { '/tmp/test' => 'test_file' }
      cache = cache_connection.instance_variable_get(:@cache)
      cache[:file].must_equal(assert)
    end
  end

  describe 'run command' do
    it 'run command with caching' do
      connection.expects(:run_command_via_connection).once.returns('test_user')
      cache_connection.run_command('whoami').must_equal('test_user')
      cache_connection.run_command('whoami').must_equal('test_user')
      assert = { 'whoami' => 'test_user' }
      cache = cache_connection.instance_variable_get(:@cache)
      cache[:command].must_equal(assert)
    end
  end
end
