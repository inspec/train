# encoding: utf-8
require 'helper'
require 'train/transports/mock'
require 'train/extras'

describe 'file common' do
  let(:cls) { Train::Extras::WindowsFile }
  let(:backend) {
    backend = Train::Transports::Mock.new.connection
    backend.mock_os({ family: 'windows' })
    backend
  }

  it 'provides the full path' do
    cls.new(backend, 'C:\dir\file').path.must_equal 'C:\dir\file'
  end

  it 'provides the basename to a unix path' do
    cls.new(backend, 'C:\dir\file').basename.must_equal 'file'
  end

  it 'provides the full path with whitespace' do
    wf = cls.new(backend, 'C:\Program Files\file name')
    wf.path.must_equal 'C:\Program Files\file name'
    wf.basename.must_equal 'file name'
  end

  it 'reads file contents' do
    out = rand.to_s
    backend.mock_command('Get-Content("path") | Out-String', out)
    cls.new(backend, 'path').content.must_equal out
  end

  it 'check escaping of invalid chars in path' do
    wf = cls.new(nil, nil)
    wf.sanitize_filename('c:/test') .must_equal 'c:/test'
    wf.sanitize_filename('c:/test directory') .must_equal 'c:/test directory'
    %w{ < > " * ?}.each do |char|
      wf.sanitize_filename("c:/test#{char}directory") .must_equal 'c:/testdirectory'
    end
  end

  # TODO: add all missing file tests!!
end
