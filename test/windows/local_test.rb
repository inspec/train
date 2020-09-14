# author: Christoph Hartmann
# author: Dominik Richter

require "minitest/autorun"
require "minitest/spec"
require "mocha/setup"
require "train"
require "tempfile" unless defined?(Tempfile)
require "logger"

# Loading here to ensure methods exist to be stubbed
require "train/transports/local"

describe "windows local command" do
  let(:backend) do
    # get final config
    target_config = Train.target_config({ logger: Logger.new(STDERR, level: :info) })
    # initialize train
    Train.create("local", target_config)
  end
  let(:conn) { backend.connection }

  it "verify os" do
    os = conn.os
    _(os[:name]).must_match(/windows_server.*/)
    _(os[:family]).must_equal "windows"
    _(os[:release]).must_match(/\d+(\.\d+)+/)
    _(os[:arch]).must_equal "x86_64"
  end

  it "run echo test" do
    cmd = conn.run_command('Write-Output "test"')
    _(cmd.stdout).must_equal "test\r\n"
    _(cmd.stderr).must_equal ""
    _(cmd.exit_status).must_equal 0
  end

  it "run script without exit code" do
    cmd = conn.run_command("powershell -file test/fixtures/PowerShell/exit_zero.ps1")
    _(cmd.stdout).must_equal "Hello\r\n"
    _(cmd.stderr).must_equal ""
    _(cmd.exit_status).must_equal 0
  end

  it "run script without exit code" do
    cmd = conn.run_command("powershell -file test/fixtures/PowerShell/exit_fortytwo.ps1")
    _(cmd.stdout).must_equal "Goodbye\r\n"
    _(cmd.stderr).must_equal ""
    _(cmd.exit_status).must_equal 42
  end

  it "returns exit code 1 for a script that throws" do
    cmd = conn.run_command("powershell -file test/fixtures/PowerShell/throws.ps1")
    _(cmd.stdout).must_match(/Next line throws/)
    _(cmd.stderr).must_equal ""
    _(cmd.exit_status).must_equal 1
  end

  describe "force 64 bit powershell command" do
    let(:runner) { conn.instance_variable_get(:@runner) }
    let(:powershell) { runner.instance_variable_get(:@powershell_cmd) }
    RUBY_PLATFORM_DUP = RUBY_PLATFORM.dup

    def override_platform(platform)
      ::Object.send(:remove_const, :RUBY_PLATFORM)
      ::Object.const_set(:RUBY_PLATFORM, platform)
    end

    after do
      backend.instance_variable_set(:@connection, nil)
      ::Object.send(:remove_const, :RUBY_PLATFORM)
      ::Object.const_set(:RUBY_PLATFORM, RUBY_PLATFORM_DUP)
    end

    it "use normal powershell with PipeRunner" do
      Train::Transports::Local::Connection::WindowsPipeRunner
        .any_instance
        .expects(:acquire_pipe)
        .returns("acquired")

      override_platform("x64-mingw32")
      _(powershell).must_equal "powershell"
    end

    it "use 64bit powershell with PipeRunner" do
      Train::Transports::Local::Connection::WindowsPipeRunner
        .any_instance
        .expects(:acquire_pipe)
        .returns("acquired")

      override_platform("i386-mingw32")
      _(powershell).must_equal "#{ENV["SystemRoot"]}\\sysnative\\WindowsPowerShell\\v1.0\\powershell.exe"
    end

    it "use normal powershell with ShellRunner" do
      Train::Transports::Local::Connection::WindowsPipeRunner
        .any_instance
        .expects(:acquire_pipe)
        .returns(nil)

      override_platform("x64-mingw32")
      _(runner.class).must_equal Train::Transports::Local::Connection::WindowsShellRunner
      _(powershell).must_equal "powershell"
    end

    it "use 64bit powershell with ShellRunner" do
      Train::Transports::Local::Connection::WindowsPipeRunner
        .any_instance
        .expects(:acquire_pipe)
        .returns(nil)

      override_platform("i386-mingw32")
      _(runner.class).must_equal Train::Transports::Local::Connection::WindowsShellRunner
      _(powershell).must_equal "#{ENV["SystemRoot"]}\\sysnative\\WindowsPowerShell\\v1.0\\powershell.exe"
    end
  end

  it "use powershell piping" do
    cmd = conn.run_command("New-Object -Type PSObject | Add-Member -MemberType NoteProperty -Name A -Value (Write-Output 'PropertyA') -PassThru | Add-Member -MemberType NoteProperty -Name B -Value (Write-Output 'PropertyB') -PassThru | ConvertTo-Json")
    _(cmd.stdout).must_equal "{\r\n    \"A\":  \"PropertyA\",\r\n    \"B\":  \"PropertyB\"\r\n}\r\n"
    _(cmd.stderr).must_equal ""
  end

  it "can execute a command using a named pipe" do
    SecureRandom.expects(:hex).returns("via_pipe")

    Train::Transports::Local::Connection::WindowsShellRunner
      .any_instance
      .expects(:new)
      .never

    cmd = conn.run_command('Write-Output "Create pipe"')
    _(File.exist?("//./pipe/inspec_via_pipe")).must_equal true
    _(cmd.stdout).must_equal "Create pipe\r\n"
    _(cmd.stderr).must_equal ""
  end

  it "can execute a command via ShellRunner if pipe creation fails" do
    # By forcing `acquire_pipe` to fail to return a pipe, any attempts to create
    # a `WindowsPipeRunner` object should fail. If we can still run a command,
    # then we know that it was successfully executed by `Mixlib::ShellOut`.
    Train::Transports::Local::Connection::WindowsPipeRunner
      .any_instance
      .expects(:acquire_pipe)
      .at_least_once
      .returns(nil)

    proc { Train::Transports::Local::Connection::WindowsPipeRunner.new }
      .must_raise(Train::Transports::Local::PipeError)

    cmd = conn.run_command('Write-Output "test"')
    _(cmd.stdout).must_equal "test\r\n"
    _(cmd.stderr).must_equal ""
  end

  describe "file" do
    before do
      @temp = Tempfile.new("foo")
      @temp.write("hello world")
      @temp.rewind
    end

    let(:file) { conn.file(@temp.path) }

    it "exists" do
      _(file.exist?).must_equal(true)
    end

    it "is a file" do
      _(file.file?).must_equal(true)
    end

    it "has type :file" do
      _(file.type).must_equal(:file)
    end

    it "has content" do
      _(file.content).must_equal("hello world")
    end

    it "returns basename of file" do
      file_name = ::File.basename(@temp)
      _(file.basename).must_equal(file_name)
    end

    it "has owner name" do
      _(file.owner).wont_be_nil
    end

    it "has no group name" do
      _(file.group).must_be_nil
    end

    it "has no mode" do
      _(file.mode).wont_be_nil
    end

    it "has an md5sum" do
      _(file.md5sum).wont_be_nil
    end

    it "has an sha256sum" do
      _(file.sha256sum).wont_be_nil
    end

    it "has no modified time" do
      _(file.mtime).wont_be_nil
    end

    it "has no size" do
      _(file.size).wont_be_nil
    end

    it "has size 11" do
      size = ::File.size(@temp)
      _(file.size).must_equal size
    end

    it "has no selinux_label handling" do
      _(file.selinux_label).must_be_nil
    end

    it "has product_version" do
      _(file.product_version).wont_be_nil
    end

    it "has file_version" do
      _(file.file_version).wont_be_nil
    end

    it "provides a json representation" do
      j = file.to_json
      _(j).must_be_kind_of Hash
      _(j["type"]).must_equal :file
    end

    after do
      @temp.close
      @temp.unlink
    end
  end

  describe "file" do
    before do
      @temp = Tempfile.new("foo bar")
      @temp.rewind
    end

    let(:file) { conn.file(@temp.path) }

    it 'provides the full path with whitespace for path #{@temp.path}' do
      _(file.path).must_equal @temp.path
    end

    after do
      @temp.close
      @temp.unlink
    end
  end

  after do
    # close the connection
    conn.close
  end
end
