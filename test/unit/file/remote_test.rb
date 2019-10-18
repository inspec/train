require "helper"
require "train/file/remote"

describe Train::File::Remote do
  let(:cls) { Train::File::Remote }

  def mockup(stubs)
    Class.new(cls) do
      stubs.each do |k, v|
        define_method k.to_sym do
          v
        end
      end
    end.new(nil, nil, false)
  end

  describe "basename helper" do
    def fc(path)
      mockup(type: :file, path: path)
    end

    it "works with an empty path" do
      _(fc("").basename).must_equal ""
    end

    it "separates a simple path (defaults to unix mode)" do
      _(fc("/dir/file").basename).must_equal "file"
    end

    it "separates a simple path (Unix mode)" do
      _(fc("/dir/file").basename(nil, "/")).must_equal "file"
    end

    it "separates a simple path (Windows mode)" do
      _(fc('C:\dir\file').basename(nil, '\\')).must_equal "file"
    end

    it "identifies a folder name (Unix mode)" do
      _(fc("/dir/file/").basename(nil, "/")).must_equal "file"
    end

    it "identifies a folder name (Windows mode)" do
      _(fc('C:\dir\file\\').basename(nil, '\\')).must_equal "file"
    end

    it "ignores tailing separators (Unix mode)" do
      _(fc("/dir/file///").basename(nil, "/")).must_equal "file"
    end

    it "ignores tailing separators (Windows mode)" do
      _(fc('C:\dir\file\\\\\\').basename(nil, '\\')).must_equal "file"
    end

    it "doesnt work with backward slashes (Unix mode)" do
      _(fc('C:\dir\file').basename(nil, "/")).must_equal 'C:\\dir\file'
    end

    it "doesnt work with forward slashes (Windows mode)" do
      _(fc("/dir/file").basename(nil, '\\')).must_equal "/dir/file"
    end
  end
end
