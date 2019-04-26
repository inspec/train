# encoding: utf-8
# author: Christoph Hartmann
# author: Dominik Richter

require 'minitest/autorun'
require 'minitest/spec'
require 'mocha/setup'
require 'train'
require 'tempfile'

# Loading here to ensure methods exist to be stubbed
require 'train/transports/local'

describe 'windows local command' do
  let(:backend) do
    # get final config
    target_config = Train.target_config({})
    # initialize train
    backend = Train.create('local', target_config)
  end
  let(:conn) { backend.connection }

  it 'verify os' do
    os = conn.os
    os[:name].must_equal 'windows_server_2016_datacenter'
    os[:family].must_equal "windows"
    os[:release].must_equal '6.3.9600'
    os[:arch].must_equal 'x86_64'
  end

  it 'run echo test' do
    cmd = conn.run_command('Write-Output "test"')
    cmd.stdout.must_equal "test\r\n"
    cmd.stderr.must_equal ''
  end

  describe 'force 64 bit powershell command' do
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

    it 'use normal powershell with PipeRunner' do
      Train::Transports::Local::Connection::WindowsPipeRunner
        .any_instance
        .expects(:acquire_pipe)
        .returns('acquired')

      override_platform('x64-mingw32')
      powershell.must_equal 'powershell'
    end

    it 'use 64bit powershell with PipeRunner' do
      Train::Transports::Local::Connection::WindowsPipeRunner
        .any_instance
        .expects(:acquire_pipe)
        .returns('acquired')

      override_platform('i386-mingw32')
      powershell.must_equal "#{ENV['SystemRoot']}\\sysnative\\WindowsPowerShell\\v1.0\\powershell.exe"
    end

    it 'use normal powershell with ShellRunner' do
      Train::Transports::Local::Connection::WindowsPipeRunner
        .any_instance
        .expects(:acquire_pipe)
        .returns(nil)

      override_platform('x64-mingw32')
      runner.class.must_equal Train::Transports::Local::Connection::WindowsShellRunner
      powershell.must_equal 'powershell'
    end

    it 'use 64bit powershell with ShellRunner' do
      Train::Transports::Local::Connection::WindowsPipeRunner
        .any_instance
        .expects(:acquire_pipe)
        .returns(nil)

      override_platform('i386-mingw32')
      runner.class.must_equal Train::Transports::Local::Connection::WindowsShellRunner
      powershell.must_equal "#{ENV['SystemRoot']}\\sysnative\\WindowsPowerShell\\v1.0\\powershell.exe"
    end
  end

  it 'use powershell piping' do
    cmd = conn.run_command("New-Object -Type PSObject | Add-Member -MemberType NoteProperty -Name A -Value (Write-Output 'PropertyA') -PassThru | Add-Member -MemberType NoteProperty -Name B -Value (Write-Output 'PropertyB') -PassThru | ConvertTo-Json")
    cmd.stdout.must_equal "{\r\n    \"A\":  \"PropertyA\",\r\n    \"B\":  \"PropertyB\"\r\n}\r\n"
    cmd.stderr.must_equal ''
  end

  it 'can execute a command using a named pipe' do
    SecureRandom.expects(:hex).returns('via_pipe')

    Train::Transports::Local::Connection::WindowsShellRunner
      .any_instance
      .expects(:new)
      .never

    cmd = conn.run_command('Write-Output "Create pipe"')
    File.exist?('//./pipe/inspec_via_pipe').must_equal true
    cmd.stdout.must_equal "Create pipe\r\n"
    cmd.stderr.must_equal ''
  end

  it 'can execute a command via ShellRunner if pipe creation fails' do
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
    cmd.stdout.must_equal "test\r\n"
    cmd.stderr.must_equal ''
  end

  describe 'file' do
    before do
      @temp = Tempfile.new('foo')
      @temp.write("hello world")
      @temp.rewind
    end

    let(:file) { conn.file(@temp.path) }

    it 'exists' do
      file.exist?.must_equal(true)
    end

    it 'is a file' do
      file.file?.must_equal(true)
    end

    it 'has type :file' do
      file.type.must_equal(:file)
    end

    it 'has content' do
      file.content.must_equal("hello world")
    end

    it 'returns basename of file' do
      file_name = ::File.basename(@temp)
      file.basename.must_equal(file_name)
    end

    it 'has owner name' do
      file.owner.wont_be_nil
    end

    it 'has no group name' do
      file.group.must_be_nil
    end

    it 'has no mode' do
      file.mode.wont_be_nil
    end

    it 'has an md5sum' do
      file.md5sum.wont_be_nil
    end

    it 'has an sha256sum' do
      file.sha256sum.wont_be_nil
    end

    it 'has no modified time' do
      file.mtime.wont_be_nil
    end

    it 'has no size' do
      file.size.wont_be_nil
    end

    it 'has size 11' do
      size = ::File.size(@temp)
      file.size.must_equal size
    end

    it 'has no selinux_label handling' do
      file.selinux_label.must_be_nil
    end

    it 'has product_version' do
      file.product_version.wont_be_nil
    end

    it 'has file_version' do
      file.file_version.wont_be_nil
    end

    it 'provides a json representation' do
      j = file.to_json
      j.must_be_kind_of Hash
      j['type'].must_equal :file
    end

    after do
      @temp.close
      @temp.unlink
    end
  end

  describe 'file' do
    before do
      @temp = Tempfile.new('foo bar')
      @temp.rewind
    end

    let(:file) { conn.file(@temp.path) }

    it 'provides the full path with whitespace for path #{@temp.path}' do
      file.path.must_equal @temp.path
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
