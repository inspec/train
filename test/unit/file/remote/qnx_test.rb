require 'helper'
require 'train/transports/local'
require 'train/file/remote/qnx'
require 'train/transports/mock'

describe Train::File::Remote::Qnx do
  let(:cls) { Train::File::Remote::Qnx }
  let(:backend) {
    backend = Train::Transports::Mock.new.connection
    backend.mock_os({ family: 'qnx' })
    backend
  }

  it 'returns file contents when the file exists' do
    out = rand.to_s
    backend.mock_command('cat path', out)
    file = cls.new(backend, 'path')
    file.stubs(:exist?).returns(true)
    file.content.must_equal out
  end

  it 'returns nil contents when the file does not exist' do
    file = cls.new(backend, 'path')
    file.stubs(:exist?).returns(false)
    file.content.must_be_nil
  end

  it 'returns a file type' do
    backend.mock_command('file path', 'blah directory blah')
    cls.new(backend, 'path').type.must_equal :directory
  end

  it 'returns a directory type' do
    backend.mock_command('file path', 'blah regular file blah')
    cls.new(backend, 'path').type.must_equal :file
  end

  it 'raises exception for unimplemented methods' do
    file = cls.new(backend, 'path')
    %w{mode owner group uid gid mtime size selinux_label link_path mounted stat}.each do |m|
      proc { file.send(m) }.must_raise NotImplementedError
    end
  end

  describe '#md5sum' do
    it 'raises an error matching /command not found/' do
      stderr = 'md5sum: command not found'
      backend.mock_command('md5sum /tmp/testfile', nil, stderr, 1)
      proc { cls.new(backend, '/tmp/testfile').md5sum }
        .must_raise RuntimeError, /md5sum: command not found/
    end
  end

  describe '#sha256sum' do
    let(:sha256_checksum) {
      '491260aaa6638d4a64c714a17828c3d82bad6ca600c9149b3b3350e91bcd283d'
    }

    it 'calculates the correct sha256sum on the `qnx` platform family' do
      output = "#{sha256_checksum} /tmp/testfile"
      backend.mock_command('shasum -a 256 /tmp/testfile', output)
      cls.new(backend, '/tmp/testfile').sha256sum.must_equal sha256_checksum
    end
  end
end
