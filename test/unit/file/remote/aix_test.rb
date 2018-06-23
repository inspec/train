require 'helper'
require 'train/transports/local'
require 'train/file/remote/aix'
require 'train/transports/mock'

describe Train::File::Remote::Aix do
  let(:cls) { Train::File::Remote::Aix }
  let(:backend) {
    backend = Train::Transports::Mock.new.connection
    backend.mock_os({ name: 'aix', family: 'unix' })
    backend
  }

  it 'returns a nil link_path if the object is not a symlink' do
    file = cls.new(backend, 'path')
    file.stubs(:symlink?).returns(false)
    file.link_path.must_be_nil
  end

  it 'returns a correct link_path' do
    file = cls.new(backend, 'path')
    file.stubs(:symlink?).returns(true)
    backend.mock_command("perl -e 'print readlink shift' path", 'our_link_path')
    file.link_path.must_equal 'our_link_path'
  end

  it 'returns a correct shallow_link_path' do
    file = cls.new(backend, 'path')
    file.stubs(:symlink?).returns(true)
    backend.mock_command("perl -e 'print readlink shift' path", 'our_link_path')
    file.link_path.must_equal 'our_link_path'
  end
end
