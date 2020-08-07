describe "file interface" do
  let(:backend) { get_backend.call }

  describe "regular file" do
    let(:file) { backend.file("/tmp/file") }

    it "exists" do
      _(file.exist?).must_equal(true)
    end

    it "is a file" do
      _(file.file?).must_equal(true)
    end

    it "has type :file" do
      _(file.type).must_equal(:file)
    end

    it "has content" do
      _(file.content).must_equal("hello world")
    end

    it "has owner name root" do
      _(file.owner).must_equal("root")
    end

    it "has group name" do
      _(file.group).must_equal(Test.root_group(backend.os))
    end

    it "has mode 0765" do
      _(file.mode).must_equal(00765)
    end

    it "checks mode? 0765" do
      _(file.mode?(00765)).must_equal(true)
    end

    it "doesn't check mode? 0764" do
      _(file.mode?(00764)).must_equal(false)
    end

    it "has no link_path" do
      _(file.link_path).must_be_nil
    end

    it "has an md5sum" do
      _(file.md5sum).must_equal("5eb63bbbe01eeed093cb22bb8f5acdc3")
    end

    it "has an sha256sum" do
      _(file.sha256sum).must_equal("b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9")
    end

    it "has a modified time" do
      _(file.mtime).must_be_close_to(Time.now.to_i - Test.mtime / 2, Test.mtime)
    end

    it "has size" do
      # Must be around 11 Bytes, +- 4
      _(file.size).must_be_close_to(11, 4)
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

    it "provides a json representation" do
      j = file.to_json
      _(j).must_be_kind_of Hash
      _(j["type"]).must_equal :file
    end
  end

  describe "regular file" do
    let(:file) { backend.file("/tmp/sfile") }
    it "has mode 7765" do
      _(file.mode).must_equal(07765)
    end
  end

  describe "regular file" do
    let(:file) { backend.file("/tmp/spaced file") }
    it "has content" do
      _(file.content).must_equal("hello space")
    end
  end
end
