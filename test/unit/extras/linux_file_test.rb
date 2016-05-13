# encoding: utf-8
require 'helper'
require 'train/transports/mock'
require 'train/extras'

describe 'file common' do
  let(:cls) { Train::Extras::LinuxFile }
  let(:backend) {
    backend = Train::Transports::Mock.new.connection
    backend.mock_os({ family: 'linux' })
    backend
  }

  def mock_stat(args, out, err = '', code = 0)
    backend.mock_command(
      "stat #{args} 2>/dev/null --printf '%s\n%f\n%U\n%u\n%G\n%g\n%X\n%Y\n%C'",
      out, err, code,
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
    cls.new(backend, 'path').content.must_equal nil
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
end
