require "helper"
require "train/transports/local"

class TransportHelper
  attr_accessor :transport

  def initialize(user_opts = {})
    opts = { platform_name: "mock", family_hierarchy: ["mock"] }.merge(user_opts)
    plat = Train::Platforms.name(opts[:platform_name])
    plat.family_hierarchy = opts[:family_hierarchy]
    plat.add_platform_methods
    Train::Platforms::Detect.stubs(:scan).returns(plat)
    @transport = Train::Transports::Local.new(user_opts)
  end
end

describe "local transport" do
  let(:transport) { TransportHelper.new.transport }
  let(:connection) { transport.connection }

  it "can be instantiated" do
    _(transport).wont_be_nil
  end

  it "gets the connection" do
    _(connection).must_be_kind_of Train::Transports::Local::Connection
  end

  it "provides a uri" do
    _(connection.uri).must_equal "local://"
  end

  it "doesnt wait to be read" do
    _(connection.wait_until_ready).must_be_nil
  end

  it "inspects with readable output" do
    _(connection.inspect).must_match(/Train::Transports::Local::Connection\[\w+\]/)
  end

  it "can be closed" do
    _(connection.close).must_be_nil
  end

  it "has no login command" do
    _(connection.login_command).must_be_nil
  end

  it "provides a run_command_via_connection method" do
    methods = connection.class.private_instance_methods(false)
    _(methods.include?(:run_command_via_connection)).must_equal true
  end

  it "provides a file_via_connection method" do
    methods = connection.class.private_instance_methods(false)
    _(methods.include?(:file_via_connection)).must_equal true
  end

  describe "when overriding runner selection" do
    it "can select the `GenericRunner`" do
      Train::Transports::Local::Connection::GenericRunner
        .expects(:new)

      Train::Transports::Local::Connection::WindowsPipeRunner
        .expects(:new)
        .never

      Train::Transports::Local::Connection::WindowsShellRunner
        .expects(:new)
        .never

      Train::Transports::Local::Connection.new(command_runner: :generic)
    end

    it "can select the `WindowsPipeRunner`" do
      Train::Transports::Local::Connection::GenericRunner
        .expects(:new)
        .never

      Train::Transports::Local::Connection::WindowsPipeRunner
        .expects(:new)

      Train::Transports::Local::Connection::WindowsShellRunner
        .expects(:new)
        .never

      Train::Transports::Local::Connection.new(command_runner: :windows_pipe)
    end

    it "can select the `WindowsShellRunner`" do
      Train::Transports::Local::Connection::GenericRunner
        .expects(:new)
        .never

      Train::Transports::Local::Connection::WindowsPipeRunner
        .expects(:new)
        .never

      Train::Transports::Local::Connection::WindowsShellRunner
        .expects(:new)

      Train::Transports::Local::Connection.new(command_runner: :windows_shell)
    end

    it "throws a RuntimeError when an invalid runner type is passed" do
      _ { Train::Transports::Local::Connection.new(command_runner: :nope ) }
        .must_raise(RuntimeError, "Runner type `:nope` not supported")
    end
  end

  describe "when running a local command" do
    let(:cmd_runner) { Minitest::Mock.new }

    def mock_run_cmd(cmd, &block)
      cmd_runner.expect :run_command, nil
      cmd_runner.expect :timeout=, nil, [nil]
      Mixlib::ShellOut.stub :new, cmd_runner do |*args|
        yield
      end
    end

    it "gets stdout" do
      mock_run_cmd(rand) do
        x = rand
        cmd_runner.expect :stdout, x
        cmd_runner.expect :stderr, nil
        cmd_runner.expect :exitstatus, nil
        _(connection.run_command(rand).stdout).must_equal x
      end
    end

    it "gets stderr" do
      mock_run_cmd(rand) do
        x = rand
        cmd_runner.expect :stdout, nil
        cmd_runner.expect :stderr, x
        cmd_runner.expect :exitstatus, nil
        _(connection.run_command(rand).stderr).must_equal x
      end
    end

    it "gets exit_status" do
      mock_run_cmd(rand) do
        x = rand
        cmd_runner.expect :stdout, nil
        cmd_runner.expect :stderr, nil
        cmd_runner.expect :exitstatus, x
        _(connection.run_command(rand).exit_status).must_equal x
      end
    end
  end

  describe "when running on Windows" do
    let(:connection) do
      TransportHelper.new(family_hierarchy: ["windows"]).transport.connection
    end
    let(:runner) { mock }

    it "uses `WindowsPipeRunner` by default" do
      Train::Transports::Local::Connection::WindowsPipeRunner
        .expects(:new)
        .returns(runner)

      Train::Transports::Local::Connection::WindowsShellRunner
        .expects(:new)
        .never

      runner.expects(:run_command).with("not actually executed", {})
      connection.run_command("not actually executed")
    end

    it "uses `WindowsShellRunner` when a named pipe is not available" do
      Train::Transports::Local::Connection::WindowsPipeRunner
        .expects(:new)
        .raises(Train::Transports::Local::PipeError)

      Train::Transports::Local::Connection::WindowsShellRunner
        .expects(:new)
        .returns(runner)

      runner.expects(:run_command).with("not actually executed", {})
      connection.run_command("not actually executed")
    end
  end

  describe "WindowsPipeRunner" do
    let(:pipe_runner_class) { Train::Transports::Local::Connection::WindowsPipeRunner }

    describe "#current_windows_user" do
      let(:runner) do
        pipe_runner_class.allocate.tap do |r|
          r.instance_variable_set(:@powershell_cmd, "powershell")
        end
      end

      it "returns user from WindowsIdentity when available" do
        runner.expects(:`).with('powershell -Command "[System.Security.Principal.WindowsIdentity]::GetCurrent().Name"').returns("DOMAIN\\testuser\n")
        result = runner.send(:current_windows_user)
        _(result).must_equal "DOMAIN\\testuser"
      end

      it "falls back to whoami when WindowsIdentity returns empty" do
        runner.expects(:`).with('powershell -Command "[System.Security.Principal.WindowsIdentity]::GetCurrent().Name"').returns("\n")
        runner.expects(:`).with("whoami").returns("domain\\fallbackuser\n")
        result = runner.send(:current_windows_user)
        _(result).must_equal "domain\\fallbackuser"
      end

      it "falls back to whoami when WindowsIdentity returns nil-like value" do
        runner.expects(:`).with('powershell -Command "[System.Security.Principal.WindowsIdentity]::GetCurrent().Name"').returns("")
        runner.expects(:`).with("whoami").returns("localuser\n")
        result = runner.send(:current_windows_user)
        _(result).must_equal "localuser"
      end

      it "raises error when both methods fail to return a user" do
        runner.expects(:`).with('powershell -Command "[System.Security.Principal.WindowsIdentity]::GetCurrent().Name"').returns("")
        runner.expects(:`).with("whoami").returns("")
        _ { runner.send(:current_windows_user) }.must_raise RuntimeError
      end
    end

    describe "#pipe_owned_by_current_user?" do
      let(:runner) do
        pipe_runner_class.allocate.tap do |r|
          r.instance_variable_set(:@powershell_cmd, "powershell")
        end
      end

      it "returns [nil, current_user, false] when pipe does not exist" do
        runner.expects(:`).with('powershell -Command "Test-Path \\\\.\\pipe\\test_pipe"').returns("false\n")
        runner.expects(:current_windows_user).returns("DOMAIN\\testuser")
        owner, current_user, is_owner = runner.send(:pipe_owned_by_current_user?, "test_pipe")
        _(owner).must_be_nil
        _(current_user).must_equal "DOMAIN\\testuser"
        _(is_owner).must_equal false
      end

      it "returns [owner, current_user, true] when pipe exists and is owned by current user" do
        runner.expects(:`).with('powershell -Command "Test-Path \\\\.\\pipe\\test_pipe"').returns("true\n")
        runner.expects(:current_windows_user).returns("DOMAIN\\testuser")
        runner.expects(:`).with('powershell -Command "(Get-Acl \\\\.\\pipe\\test_pipe).Owner" 2>&1').returns("DOMAIN\\testuser\n")
        owner, current_user, is_owner = runner.send(:pipe_owned_by_current_user?, "test_pipe")
        _(owner).must_equal "DOMAIN\\testuser"
        _(current_user).must_equal "DOMAIN\\testuser"
        _(is_owner).must_equal true
      end

      it "returns [owner, current_user, false] when pipe is owned by different user" do
        runner.expects(:`).with('powershell -Command "Test-Path \\\\.\\pipe\\test_pipe"').returns("true\n")
        runner.expects(:current_windows_user).returns("DOMAIN\\testuser")
        runner.expects(:`).with('powershell -Command "(Get-Acl \\\\.\\pipe\\test_pipe).Owner" 2>&1').returns("DOMAIN\\otheruser\n")
        owner, current_user, is_owner = runner.send(:pipe_owned_by_current_user?, "test_pipe")
        _(owner).must_equal "DOMAIN\\otheruser"
        _(current_user).must_equal "DOMAIN\\testuser"
        _(is_owner).must_equal false
      end

      it "performs case-insensitive comparison for ownership" do
        runner.expects(:`).with('powershell -Command "Test-Path \\\\.\\pipe\\test_pipe"').returns("true\n")
        runner.expects(:current_windows_user).returns("domain\\TESTUSER")
        runner.expects(:`).with('powershell -Command "(Get-Acl \\\\.\\pipe\\test_pipe).Owner" 2>&1').returns("DOMAIN\\testuser\n")
        _owner, _current_user, is_owner = runner.send(:pipe_owned_by_current_user?, "test_pipe")
        _(is_owner).must_equal true
      end
    end

    describe "#acquire_pipe" do
      let(:runner) do
        pipe_runner_class.allocate.tap do |r|
          r.instance_variable_set(:@powershell_cmd, "powershell")
          r.instance_variable_set(:@server_pid, nil)
        end
      end

      before do
        runner.stubs(:require).with("win32/process").returns(true)
      end

      it "raises PipeError when pipe is owned by unauthorized user" do
        runner.expects(:start_pipe_server).with(anything).returns(12345)
        runner.expects(:pipe_owned_by_current_user?).with(anything).returns(["DOMAIN\\otheruser", "DOMAIN\\testuser", false])
        runner.stubs(:close)

        _ { runner.send(:acquire_pipe) }.must_raise Train::Transports::Local::PipeError
      end

      it "waits for pipe to be created before verifying ownership" do
        mock_pipe = mock("pipe")
        runner.expects(:start_pipe_server).with(anything).returns(12345)
        runner.expects(:pipe_owned_by_current_user?).with(anything).twice.returns(
          [nil, "DOMAIN\\testuser", false],
          ["DOMAIN\\testuser", "DOMAIN\\testuser", true]
        )
        runner.expects(:open).with(anything, "r+").returns(mock_pipe)
        runner.stubs(:close)

        result = runner.send(:acquire_pipe)
        _(result).must_equal mock_pipe
      end
    end
  end
end
