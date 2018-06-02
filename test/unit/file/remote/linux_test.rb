require 'helper'
require 'train/transports/local'
require 'train/file/remote/linux'
require 'train/transports/mock'

describe Train::File::Remote::Linux do
  let(:cls) { Train::File::Remote::Linux }
  let(:backend) {
    backend = Train::Transports::Mock.new.connection
    backend.mock_os({ name: 'linux', family: 'unix' })
    backend
  }

  def mock_stat(args, out, err = '', code = 0)
    backend.mock_command(
      "stat #{args} 2>/dev/null --printf '%s\n%f\n%U\n%u\n%G\n%g\n%X\n%Y\n%C'",
      out, err, code
    )
  end

  it 'works on nil path' do
    cls.new(backend, nil).path.must_equal ''
  end

  it 'provides the full path' do
    cls.new(backend, '/dir/file').path.must_equal '/dir/file'
  end

  it 'provides the basename to a unix path' do
    cls.new(backend, '/dir/file').basename.must_equal 'file'
  end

  it 'reads file contents' do
    out = rand.to_s
    backend.mock_command('cat path || echo -n', out)
    cls.new(backend, 'path').content.must_equal out
  end

  it 'reads file contents' do
    backend.mock_command('cat path || echo -n', '')
    mock_stat('-L path', '', 'some error...', 1)
    cls.new(backend, 'path').content.must_be_nil
  end

  it 'reads file contents' do
    out = rand.to_s
    backend.mock_command('cat /spaced\\ path || echo -n', out)
    cls.new(backend, '/spaced path').content.must_equal out
  end

  it 'checks for file existance' do
    backend.mock_command('test -e path', true)
    cls.new(backend, 'path').exist?.must_equal true
  end

  it 'checks for file existance' do
    backend.mock_command('test -e path', nil, nil, 1)
    cls.new(backend, 'path').exist?.must_equal false
  end

  it 'retrieves the link path via #path()' do
    out = rand.to_s
    mock_stat('path', "13\na1ff\nz\n1001\nz\n1001\n1444573475\n1444573475\n?")
    backend.mock_command('readlink -n path -f', out)
    cls.new(backend, 'path').path.must_equal File.join(Dir.pwd, out)
  end

  it 'retrieves the link path' do
    out = rand.to_s
    mock_stat('path', "13\na1ff\nz\n1001\nz\n1001\n1444573475\n1444573475\n?")
    backend.mock_command('readlink -n path -f', out)
    cls.new(backend, 'path').link_path.must_equal File.join(Dir.pwd, out)
  end

  it 'provide the source path' do
    cls.new(backend, 'path').source_path.must_equal 'path'
  end

  it 'checks a mounted path' do
    backend.mock_command("mount | grep -- ' on /mount/path '", rand.to_s)
    cls.new(backend, '/mount/path').mounted?.must_equal true
  end

  it 'has nil product version' do
    cls.new(backend, 'path').product_version.must_be_nil
  end

  it 'has nil file version' do
    cls.new(backend, 'path').file_version.must_be_nil
  end

  describe 'stat on a file' do
    before { mock_stat('-L path', "13\na1ff\nz\n1001\nz2\n1002\n1444573475\n1444573475\nlabels") }
    let(:f) { cls.new(backend, 'path') }

    it 'retrieves the file type' do
      f.type.must_equal :symlink
    end

    it 'retrieves the file mode' do
      f.mode.must_equal 00777
    end

    it 'retrieves the file owner' do
      f.owner.must_equal 'z'
    end

    it 'retrieves the file uid' do
      f.uid.must_equal 1001
    end

    it 'retrieves the file group' do
      f.group.must_equal 'z2'
    end

    it 'retrieves the file gid' do
      f.gid.must_equal 1002
    end

    it 'retrieves the file mtime' do
      f.mtime.must_equal 1444573475
    end

    it 'retrieves the file size' do
      f.size.must_equal 13
    end

    it 'retrieves the file selinux_label' do
      f.selinux_label.must_equal 'labels'
    end
  end

  describe 'stat on the source file' do
    before { mock_stat('path', "13\na1ff\nz\n1001\nz2\n1002\n1444573475\n1444573475\nlabels") }
    let(:f) { cls.new(backend, 'path').source }

    it 'retrieves the file type' do
      f.type.must_equal :symlink
    end

    it 'retrieves the file mode' do
      f.mode.must_equal 00777
    end

    it 'retrieves the file owner' do
      f.owner.must_equal 'z'
    end

    it 'retrieves the file uid' do
      f.uid.must_equal 1001
    end

    it 'retrieves the file group' do
      f.group.must_equal 'z2'
    end

    it 'retrieves the file gid' do
      f.gid.must_equal 1002
    end

    it 'retrieves the file mtime' do
      f.mtime.must_equal 1444573475
    end

    it 'retrieves the file size' do
      f.size.must_equal 13
    end

    it 'retrieves the file selinux_label' do
      f.selinux_label.must_equal 'labels'
    end
  end

  describe '#md5sum' do
    let(:md5_checksum) { '57d4c6f9d15313fd5651317e588c035d' }

    let(:ruby_md5_mock) do
      checksum_mock = mock
      checksum_mock.expects(:update).returns('')
      checksum_mock.expects(:hexdigest).returns(md5_checksum)
      checksum_mock
    end

    it 'defaults to a Ruby based checksum if other methods fail' do
      backend.mock_command('md5sum /tmp/testfile', '', '', 1)
      Digest::MD5.expects(:new).returns(ruby_md5_mock)
      cls.new(backend, '/tmp/testfile').md5sum.must_equal md5_checksum
    end

    it 'calculates the correct md5sum on the `linux` platform family' do
      output = "#{md5_checksum} /tmp/testfile"
      backend.mock_command('md5sum /tmp/testfile', output)
      cls.new(backend, '/tmp/testfile').md5sum.must_equal md5_checksum
    end
  end

  describe '#sha256sum' do
    let(:sha256_checksum) {
      '491260aaa6638d4a64c714a17828c3d82bad6ca600c9149b3b3350e91bcd283d'
    }

    let(:ruby_sha256_mock) do
      checksum_mock = mock
      checksum_mock.expects(:update).returns('')
      checksum_mock.expects(:hexdigest).returns(sha256_checksum)
      checksum_mock
    end

    it 'defaults to a Ruby based checksum if other methods fail' do
      backend.mock_command('sha256sum /tmp/testfile', '', '', 1)
      Digest::SHA256.expects(:new).returns(ruby_sha256_mock)
      cls.new(backend, '/tmp/testfile').sha256sum.must_equal sha256_checksum
    end

    it 'calculates the correct sha256sum on the `linux` platform family' do
      output = "#{sha256_checksum} /tmp/testfile"
      backend.mock_command('sha256sum /tmp/testfile', output)
      cls.new(backend, '/tmp/testfile').sha256sum.must_equal sha256_checksum
    end
  end
end
