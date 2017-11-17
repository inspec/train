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
    end
  end

  describe 'check instance method fallback' do
    it 'check os method' do
      cache_connection.respond_to?(:os).must_equal true
      cache_connection.respond_to?(:platform).must_equal true
    end

    it 'check close method' do
      cache_connection.respond_to?(:close).must_equal true
    end
  end

  describe 'load file' do
    it 'load file with caching' do
      connection.expects(:file).once.returns('test_file')
      cache_connection.file('/tmp/test').must_equal('test_file')
      cache_connection.file('/tmp/test').must_equal('test_file')
      assert = { '/tmp/test' => 'test_file' }
      cache_connection.instance_variable_get(:@file_cache).must_equal(assert)
    end
  end

  describe 'run command' do
    it 'run command with caching' do
      connection.expects(:run_command).once.returns('test_user')
      cache_connection.run_command('whoami').must_equal('test_user')
      cache_connection.run_command('whoami').must_equal('test_user')
      assert = { 'whoami' => 'test_user' }
      cache_connection.instance_variable_get(:@cmd_cache).must_equal(assert)
    end
  end
end
