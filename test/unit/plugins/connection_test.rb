# encoding: utf-8
require 'helper'

describe 'v1 Connection Plugin' do
  describe 'empty v1 connection plugin' do
    let(:cls) { Train::Plugins::Transport::BaseConnection }
    let(:connection) { cls.new({}) }

    it 'provides a close method' do
      connection.close # wont raise
    end

    it 'raises an exception for run_command' do
      proc { connection.run_command('') }.must_raise NotImplementedError
    end

    it 'raises an exception for run_command_via_connection' do
      proc { connection.run_command_via_connection('') }.must_raise NotImplementedError
    end

    it 'raises an exception for os method' do
      proc { connection.os }.must_raise NotImplementedError
    end

    it 'raises an exception for file method' do
      proc { connection.file('') }.must_raise NotImplementedError
    end

    it 'raises an exception for file_via_connection method' do
      proc { connection.file_via_connection('') }.must_raise NotImplementedError
    end

    it 'raises an exception for login command method' do
      proc { connection.login_command }.must_raise NotImplementedError
    end

    it 'can wait until ready' do
      connection.wait_until_ready # wont raise
    end

    it 'provides a default logger' do
      connection.method(:logger).call
                .must_be_instance_of(Logger)
    end

    it 'must use the user-provided logger' do
      l = rand
      cls.new({logger: l})
         .method(:logger).call.must_equal(l)
    end
  end
end
