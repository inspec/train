# encoding: utf-8
# author: Christoph Hartmann
# author: Dominik Richter

require 'minitest/autorun'
require 'minitest/spec'
require 'mocha/setup'
require 'train'

describe 'windows winrm command' do
  let(:conn) {
    # get final config
    target_config = Train.target_config({
      target: ENV['train_target'],
      password: ENV['winrm_pass'],
      ssl: ENV['train_ssl'],
      self_signed: true,
    })

    # initialize train
    backend = Train.create('winrm', target_config)

    # start or reuse a connection
    conn = backend.connection
    conn
  }

  it 'verify os' do
    os = conn.os
    os[:name].must_equal 'Windows Server 2012 R2 Datacenter'
    os[:family].must_equal 'windows'
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

  describe 'verify file' do
    let(:file) { conn.file('C:\\train_test_file') }

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
      # TODO: this shouldn't include newlines that aren't in the original file
      file.content.must_equal("hello world\r\n")
    end

    it 'has owner name' do
      file.owner.wont_be_nil
    end

    it 'has no group name' do
      file.group.must_be_nil
    end

    it 'has no mode' do
      file.mode.must_be_nil
    end

    it 'has an md5sum' do
      file.md5sum.wont_be_nil
    end

    it 'has an sha256sum' do
      file.sha256sum.wont_be_nil
    end

    it 'has no modified time' do
      file.mtime.must_be_nil
    end

    it 'has no size' do
      # TODO: this really ought to be implemented
      file.size.must_be_nil
    end

    it 'has no selinux label handling' do
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
  end

  after do
    # close the connection
    conn.close
  end
end
