require "helper"

describe Train::File do
  let(:cls) { Train::File }
  let(:new_cls) { cls.new(nil, "/temp/file", false) }

  def mockup(stubs)
    Class.new(cls) do
      stubs.each do |k, v|
        define_method k.to_sym do
          v
        end
      end
    end.new(nil, nil, false)
  end

  it "has the default type of unknown" do
    _(new_cls.type).must_equal :unknown
  end

  it "throws Not implemented error for exist?" do
    # proc { Train.validate_backend({ host: rand }) }.must_raise Train::UserError
    _ { new_cls.exist? }.must_raise NotImplementedError
  end

  it "throws Not implemented error for mode" do
    _ { new_cls.mode }.must_raise NotImplementedError
  end

  it "throws Not implemented error for owner" do
    _ { new_cls.owner }.must_raise NotImplementedError
  end

  it "throws Not implemented error for group" do
    _ { new_cls.group }.must_raise NotImplementedError
  end

  it "throws Not implemented error for uid" do
    _ { new_cls.uid }.must_raise NotImplementedError
  end

  it "throws Not implemented error for gid" do
    _ { new_cls.gid }.must_raise NotImplementedError
  end

  it "throws Not implemented error for content" do
    _ { new_cls.content }.must_raise NotImplementedError
  end

  it "throws Not implemented error for mtime" do
    _ { new_cls.mtime }.must_raise NotImplementedError
  end

  it "throws Not implemented error for size" do
    _ { new_cls.size }.must_raise NotImplementedError
  end

  it "throws Not implemented error for selinux_label" do
    _ { new_cls.selinux_label }.must_raise NotImplementedError
  end

  it "return path of file" do
    _(new_cls.path).must_equal("/temp/file")
  end

  it "set product_version to nil" do
    _(new_cls.product_version).must_be_nil
  end

  it "set product_version to nil" do
    _(new_cls.file_version).must_be_nil
  end

  describe "type" do
    it "recognized type == file" do
      fc = mockup(type: :file)
      _(fc.file?).must_equal true
    end

    it "recognized type == block_device" do
      fc = mockup(type: :block_device)
      _(fc.block_device?).must_equal true
    end

    it "recognized type == character_device" do
      fc = mockup(type: :character_device)
      _(fc.character_device?).must_equal true
    end

    it "recognized type == socket" do
      fc = mockup(type: :socket)
      _(fc.socket?).must_equal true
    end

    it "recognized type == directory" do
      fc = mockup(type: :directory)
      _(fc.directory?).must_equal true
    end

    it "recognized type == pipe" do
      fc = mockup(type: :pipe)
      _(fc.pipe?).must_equal true
    end

    it "recognized type == symlink" do
      fc = mockup(type: :symlink)
      _(fc.symlink?).must_equal true
    end
  end

  describe "version" do
    it "recognized wrong version" do
      fc = mockup(product_version: rand, file_version: rand)
      _(fc.version?(rand)).must_equal false
    end

    it "recognized product_version" do
      x = rand
      fc = mockup(product_version: x, file_version: rand)
      _(fc.version?(x)).must_equal true
    end

    it "recognized file_version" do
      x = rand
      fc = mockup(product_version: rand, file_version: x)
      _(fc.version?(x)).must_equal true
    end
  end
end
