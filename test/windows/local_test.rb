# encoding: utf-8
# author: Christoph Hartmann
# author: Dominik Richter

require 'minitest/autorun'
require 'minitest/spec'
require 'mocha/setup'
require 'train'
require 'tempfile'

describe 'windows local command' do
  let(:conn) {
    # get final config
    target_config = Train.target_config({})
    # initialize train
    backend = Train.create('local', target_config)

    # start or reuse a connection
    conn = backend.connection
    conn
  }

  it 'verify os' do
    os = conn.os
    os[:name].must_equal 'Windows Server 2012 R2 Datacenter'
    os[:family].must_equal "windows"
    os[:release].must_equal '6.3.9600'
    os[:arch].must_equal 'x86_64'
  end

  it 'run echo test' do
    cmd = conn.run_command('Write-Output "test"')
    cmd.stdout.must_equal "test\r\n"
    cmd.stderr.must_equal ''
  end

  it 'use powershell piping' do
    cmd = conn.run_command("New-Object -Type PSObject | Add-Member -MemberType NoteProperty -Name A -Value (Write-Output 'PropertyA') -PassThru | Add-Member -MemberType NoteProperty -Name B -Value (Write-Output 'PropertyB') -PassThru | ConvertTo-Json")
    cmd.stdout.must_equal "{\r\n    \"A\":  \"PropertyA\",\r\n    \"B\":  \"PropertyB\"\r\n}\r\n"
    cmd.stderr.must_equal ''
  end

  it 'uses a named pipe if available' do
    # Must call `:conn` early so we can stub `SecureRandom`
    connection = conn

    # Verify pipe is created by using PowerShell to check pipe location
    SecureRandom.stubwass(:hex).returns('with_pipe')
    cmd = connection.run_command('Get-ChildItem //./pipe/ | Where-Object { $_.Name -Match "inspec_with_pipe" }')
    cmd.stdout.wont_be_nil
    cmd.stderr.must_equal ''
  end

  it 'when named pipe is not available it runs `Mixlib::Shellout`' do
    # Must call `:conn` early so we can stub `:acquire_pipe`
    connection = conn

    # Prevent named pipe from being created
    Train::Transports::Local::Connection::WindowsPipeRunner
      .any_instance
      .stubs(:acquire_pipe)
      .returns(nil)

    # Verify pipe was not created by using PowerShell to check pipe location
    SecureRandom.stubs(:hex).returns('minitest')
    cmd = connection.run_command('Get-ChildItem //./pipe/ | Where-Object { $_.Name -Match "inspec_minitest" }')
    cmd.stdout.must_equal ''
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
