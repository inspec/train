# encoding: utf-8
#
# author: Dominik Richter
# author: Christoph Hartmann

require 'helper'
require 'train/transports/local'

# overwrite os detection to simplify mock tests, otherwise run_command tries to
# determine the OS first and fails the tests
class Train::Transports::Local::Connection
  class OS < OSCommon
    def initialize(backend)
      super(backend, { family: 'train_mock_os' })
    end

    def detect_family
      # no op, we do not need to detect the os
    end
  end
end

describe 'local transport' do
  let(:transport) { Train::Transports::Local.new }
  let(:connection) { transport.connection }

  it 'can be instantiated' do
    transport.wont_be_nil
  end

  it 'gets the connection' do
    connection.must_be_kind_of Train::Transports::Local::Connection
  end

  it 'provides a uri' do
    connection.uri.must_equal "local://"
  end

  it 'doesnt wait to be read' do
    connection.wait_until_ready.must_be_nil
  end

  it 'can be closed' do
    connection.close.must_be_nil
  end

  it 'has no login command' do
    connection.login_command.must_be_nil
  end

  describe 'when running a local command' do
    let(:cmd_runner) { Minitest::Mock.new }

    def mock_run_cmd(cmd, &block)
      cmd_runner.expect :run_command, nil
      Mixlib::ShellOut.stub :new, cmd_runner do |*args|
        block.call()
      end
    end

    it 'gets stdout' do
      mock_run_cmd(rand) do
        x = rand
        cmd_runner.expect :stdout, x
        cmd_runner.expect :stderr, nil
        cmd_runner.expect :exitstatus, nil
        connection.run_command(rand).stdout.must_equal x
      end
    end

    it 'gets stderr' do
      mock_run_cmd(rand) do
        x = rand
        cmd_runner.expect :stdout, nil
        cmd_runner.expect :stderr, x
        cmd_runner.expect :exitstatus, nil
        connection.run_command(rand).stderr.must_equal x
      end
    end

    it 'gets exit_status' do
      mock_run_cmd(rand) do
        x = rand
        cmd_runner.expect :stdout, nil
        cmd_runner.expect :stderr, nil
        cmd_runner.expect :exitstatus, x
        connection.run_command(rand).exit_status.must_equal x
      end
    end
  end
end
