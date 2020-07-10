describe "file interface" do
  let(:backend) { get_backend.call }

  describe "a folder" do
    let(:file) { backend.file("/tmp/folder") }

    it "exists" do
      _(file.exist?).must_equal(true)
    end

    it "is a directory" do
      _(file.directory?).must_equal(true)
    end

    it "has type :directory" do
      _(file.type).must_equal(:directory)
    end

    case get_backend.call.os[:family]
    when "freebsd"
      it "has freebsd folder content behavior" do
        _(file.content).must_equal("\u0003\u0000")
      end

      it "has an md5sum" do
        _(file.md5sum).must_equal("598f4fe64aefab8f00bcbea4c9239abf")
      end

      it "has an sha256sum" do
        _(file.sha256sum).must_equal("9b4fb24edd6d1d8830e272398263cdbf026b97392cc35387b991dc0248a628f9")
      end

    else
      it "has no content" do
        _(file.content).must_be_nil
      end

      it "raises an error if md5sum is attempted" do
        _ { file.md5sum }.must_raise RuntimeError
      end

      it "raises an error if sha256sum is attempted" do
        _ { file.sha256sum }.must_raise RuntimeError
      end
    end

    it "has owner name root" do
      _(file.owner).must_equal("root")
    end

    it "has group name" do
      _(file.group).must_equal(Test.root_group(backend.os))
    end

    it "has mode 0567" do
      _(file.mode).must_equal(00567)
    end

    it "checks mode? 0567" do
      _(file.mode?(00567)).must_equal(true)
    end

    it "has no link_path" do
      _(file.link_path).must_be_nil
    end

    it "has a modified time" do
      _(file.mtime).must_be_close_to(Time.now.to_i - Test.mtime / 2, Test.mtime)
    end

    it "has inode size" do
      _(file.size).must_be_close_to(4096, 4096)
    end

    it "has selinux label handling" do
      res = Test.selinux_label(backend, file.path)
      _(file.selinux_label).must_equal(res)
    end

    it "has no product_version" do
      _(file.product_version).must_be_nil
    end

    it "has no file_version" do
      _(file.file_version).must_be_nil
    end
  end
end
