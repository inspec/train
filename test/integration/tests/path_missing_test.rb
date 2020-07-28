describe "file interface" do
  let(:backend) { get_backend.call }

  describe "a path that doesn't exist" do
    let(:file) do
      backend.file("/do_not_create_this_path_please_or_my_tests_will_fail")
    end

    it "does not exist" do
      _(file.exist?).must_equal(false)
    end

    it "is not a file" do
      _(file.file?).must_equal(false)
    end

    it "has type nil" do
      _(file.type).must_be_nil
    end

    it "has no content" do
      _(file.content).must_be_nil
    end

    it "has no owner" do
      _(file.owner).must_be_nil
    end

    it "has no group" do
      _(file.group).must_be_nil
    end

    it "has mode nil" do
      _(file.mode).must_be_nil
    end

    it "checks mode? nil" do
      _(file.mode?(nil)).must_equal(true)
    end

    it "has no link_path" do
      _(file.link_path).must_be_nil
    end

    it "raises an error if md5sum is attempted" do
      _ { file.md5sum }.must_raise RuntimeError
    end

    it "raises an error if sha256sum is attempted" do
      _ { file.sha256sum }.must_raise RuntimeError
    end

    it "has a modified time" do
      _(file.mtime).must_be_nil
    end

    it "has inode size" do
      # Must be around 11 Bytes, +- 4
      _(file.size).must_be_nil
    end

    it "has no selinux_label" do
      _(file.selinux_label).must_be_nil
    end

    it "has no product_version" do
      _(file.product_version).must_be_nil
    end

    it "has no file_version" do
      _(file.file_version).must_be_nil
    end
  end
end
