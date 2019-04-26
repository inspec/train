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
    os[:name].must_equal 'windows_server_2016_datacenter'
    os[:family].must_equal 'windows'
    os[:release].must_equal '10.0.14393'
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

    it 'has the correct md5sum' do
      # Must create unique file to prevent `ERROR_SHARING_VIOLATION`
      tempfile = Tempfile.new('tempfile')
      tempfile.write('easy to hash')
      tempfile.close
      conn.file(tempfile.path).md5sum.must_equal 'c15b41ade1221a532a38d89671ffaa20'
      tempfile.unlink
    end

    it 'has the correct sha256sum' do
      # Must create unique file to prevent `ERROR_SHARING_VIOLATION`
      tempfile = Tempfile.new('tempfile')
      tempfile.write('easy to hash')
      tempfile.close
      conn.file(tempfile.path).sha256sum.must_equal '24ae25354d5f697566e715cd46e1df2f490d0b8367c21447962dbf03bf7225ba'
      tempfile.unlink
    end

    it 'has no modified time' do
      file.mtime.must_be_nil
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

    # TODO: This is not failing in manual testing
    # it 'returns basname of file' do
    #   basename = ::File.basename(@temp)
    #   file.basename.must_equal basename
    # end

    it 'has file_version' do
      file.file_version.wont_be_nil
    end

    it 'returns nil for mounted' do
      file.mounted.must_be_nil
    end

    it 'has no link_path' do
      file.link_path.must_be_nil
    end

    it 'has no uid' do
      file.uid.must_be_nil
    end

    it 'has no gid' do
      file.gid.must_be_nil
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
      @temp.write("hello world")
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
