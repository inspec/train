# encoding: utf-8

describe 'file interface' do
  let(:backend) { get_backend.call }

  describe 'a folder' do
    let(:file) { backend.file('/tmp/folder') }

    it 'exists' do
      file.exist?.must_equal(true)
    end

    it 'is a directory' do
      file.directory?.must_equal(true)
    end

    it 'has type :directory' do
      file.type.must_equal(:directory)
    end

    it 'has the correct content for the platform' do
      if backend.os[:family] == 'freebsd'
        file.content.must_equal("\u0003\u0000")
      else
        file.content.must_be_nil
      end
    end

    it 'has the correct md5sum for the platform' do
      if backend.os[:family] == 'freebsd'
        file.md5sum.must_equal('598f4fe64aefab8f00bcbea4c9239abf')
      else
        file.md5sum.must_be_nil
      end
    end

    it 'has the correct sha256sum for the platform' do
      if backend.os[:family] == 'freebsd'
        file.sha256sum.must_equal('9b4fb24edd6d1d8830e272398263cdbf026b97392cc35387b991dc0248a628f9')
      else
        file.sha256sum.must_be_nil
      end
    end

    it 'has owner name root' do
      file.owner.must_equal('root')
    end

    it 'has group name' do
      file.group.must_equal(Test.root_group(backend.os))
    end

    it 'has mode 0567' do
      file.mode.must_equal(00567)
    end

    it 'checks mode? 0567' do
      file.mode?(00567).must_equal(true)
    end

    it 'has no link_path' do
      file.link_path.must_be_nil
    end

    it 'has a modified time' do
      file.mtime.must_be_close_to(Time.now.to_i - Test.mtime/2, Test.mtime)
    end

    it 'has inode size' do
      file.size.must_be_close_to(4096, 4096)
    end

    it 'has selinux label handling' do
      res = Test.selinux_label(backend, file.path)
      if res.nil?
        file.selinux_label.must_be_nil
      else
        file.selinux_label.must_equal(res)
      end
    end

    it 'has no product_version' do
      file.product_version.must_be_nil
    end

    it 'has no file_version' do
      file.file_version.must_be_nil
    end
  end
end
