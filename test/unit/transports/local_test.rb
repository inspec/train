# encoding: utf-8

require 'helper'
require 'train/transports/local'

class TransportHelper
  attr_accessor :transport

  def initialize
    Train::Platforms::Detect::Specifications::OS.load
    plat = Train::Platforms.name('mock').in_family('linux')
    plat.add_platform_methods
    Train::Platforms::Detect.stubs(:scan).returns(plat)
    @transport = Train::Transports::Local.new
  end
end

describe 'local transport' do
  let(:transport) { TransportHelper.new.transport }
  let(:connection) { transport.connection }

  it 'can be instantiated' do
    transport.wont_be_nil
  end

  it 'gets the connection' do
    connection.must_be_kind_of Train::Transports::Local::Connection
  end

  it 'provides a uri' do
    connection.uri.must_equal 'local://'
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

  it 'provides a run_command_via_connection method' do
    methods = connection.class.private_instance_methods(false)
    methods.include?(:run_command_via_connection).must_equal true
  end

  it 'provides a file_via_connection method' do
    methods = connection.class.private_instance_methods(false)
    methods.include?(:file_via_connection).must_equal true
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

  describe 'when running on Windows' do
    let(:conn) do
      Train::Platforms::Platform.any_instance.stubs(:windows?).returns(true)
      Train::Transports::Local.new.connection
    end

    let(:runner) { mock }

    it 'uses `WindowsPipeRunner` by default' do
      Train::Transports::Local::Connection::WindowsPipeRunner
        .expects(:new)
        .returns(runner)

      Train::Transports::Local::Connection::WindowsShellRunner
        .expects(:new)
        .never

      runner.expects(:run_command).with('not actually executed')
      conn.run_command('not actually executed')
    end

    it 'uses `WindowsShellRunner` when a named pipe is not available' do
      Train::Transports::Local::Connection::WindowsPipeRunner
        .expects(:new)
        .raises(Train::Transports::Local::PipeError)

      Train::Transports::Local::Connection::WindowsShellRunner
        .expects(:new)
        .returns(runner)

      runner.expects(:run_command).with('not actually executed')
      conn.run_command('not actually executed')
    end
  end
end
