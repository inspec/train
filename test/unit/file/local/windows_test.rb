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
end
