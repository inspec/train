# encoding: utf-8

require 'helper'
require 'train/transports/mock'
require 'train/file/local/windows'

describe 'file common' do
  let(:cls) { Train::File::Local::Windows }
  let(:backend) {
    backend = Train::Transports::Mock.new.connection
    backend.mock_os({ family: 'windows' })
    backend
  }

  it 'check escaping of invalid chars in path' do
    wf = cls.new(nil, nil)
    wf.sanitize_filename('c:/test') .must_equal 'c:/test'
    wf.sanitize_filename('c:/test directory') .must_equal 'c:/test directory'
    %w{ < > " * ?}.each do |char|
      wf.sanitize_filename("c:/test#{char}directory") .must_equal 'c:/testdirectory'
    end
  end

  it 'returns file version' do
    out = rand.to_s
    backend.mock_command('[System.Diagnostics.FileVersionInfo]::GetVersionInfo("path").FileVersion', out)
    cls.new(backend, 'path').file_version.must_equal out
  end

  it 'returns product version' do
    out = rand.to_s
    backend.mock_command('[System.Diagnostics.FileVersionInfo]::GetVersionInfo("path").FileVersion', out)
    cls.new(backend, 'path').file_version.must_equal out
  end

  it 'returns owner of file' do
    out = rand.to_s
    backend.mock_command('Get-Acl "path" | select -expand Owner', out)
    cls.new(backend, 'path').owner.must_equal out
  end

  describe '#md5sum' do
    let(:md5_checksum) { '4ce0c733cdcf1d2f78532bbd9ce3441d' }
    let(:filepath) { 'C:\Windows\explorer.exe' }

    let(:ruby_md5_mock) do
      checksum_mock = mock
      checksum_mock.expects(:update).returns('')
      checksum_mock.expects(:hexdigest).returns(md5_checksum)
      checksum_mock
    end

    it 'defaults to a Ruby based checksum if other methods fail' do
      backend.mock_command("CertUtil -hashfile #{filepath} MD5", '', '', 1)
      Digest::MD5.expects(:new).returns(ruby_md5_mock)
      cls.new(backend, '/tmp/testfile').md5sum.must_equal md5_checksum
    end

    it 'calculates the correct md5sum on the `windows` platform family' do
      output = <<-EOC
        MD5 hash of file C:\\Windows\\explorer.exe:\r
        4c e0 c7 33 cd cf 1d 2f 78 53 2b bd 9c e3 44 1d\r
        CertUtil: -hashfile command completed successfully.\r
      EOC

      backend.mock_command("CertUtil -hashfile #{filepath} MD5", output)
      cls.new(backend, filepath).md5sum.must_equal md5_checksum
    end
  end

  describe '#sha256sum' do
    let(:sha256_checksum) {
      '85270240a5fd51934f0627c92b2282749d071fdc9ac351b81039ced5b10f798b'
    }
    let(:filepath) { 'C:\Windows\explorer.exe' }

    let(:ruby_sha256_mock) do
      checksum_mock = mock
      checksum_mock.expects(:update).returns('')
      checksum_mock.expects(:hexdigest).returns(sha256_checksum)
      checksum_mock
    end

    it 'defaults to a Ruby based checksum if other methods fail' do
      backend.mock_command('CertUtil -hashfile #{filepath} SHA256', '', '', 1)
      Digest::SHA256.expects(:new).returns(ruby_sha256_mock)
      cls.new(backend, '/tmp/testfile').sha256sum.must_equal sha256_checksum
    end

    it 'calculates the correct sha256sum on the `windows` platform family' do
      output = <<-EOC
        SHA256 hash of file C:\\Windows\\explorer.exe:\r
        85 27 02 40 a5 fd 51 93 4f 06 27 c9 2b 22 82 74 9d 07 1f dc 9a c3 51 b8 10 39 ce d5 b1 0f 79 8b\r
        CertUtil: -hashfile command completed successfully.\r
      EOC

      backend.mock_command("CertUtil -hashfile #{filepath} SHA256", output)
      cls.new(backend, filepath).sha256sum.must_equal sha256_checksum
    end
  end
end
