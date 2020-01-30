require "helper"
require "train/transports/local"

describe Train::File::Local do
  let(:transport) { Train::Transports::Local.new }
  let(:connection) { transport.connection }

  it "gets file contents" do
    res = rand.to_s
    File.stub :read, res do
      _(connection.file(rand.to_s).content).must_equal(res)
    end
  end

  {
    exist?: :exist?,
    file?: :file?,
    socket?: :socket?,
    directory?: :directory?,
    symlink?: :symlink?,
    pipe?: :pipe?,
    character_device?: :chardev?,
    block_device?: :blockdev?,
  }.each do |method, file_method|
    it "checks if file is a #{method}" do
      File.stub file_method.to_sym, true do
        _(connection.file(rand.to_s).method(method.to_sym).call).must_equal(true)
      end
    end
  end

  it "has a friendly inspect" do
    _(connection.inspect).must_equal "Train::Transports::Local::Connection[unknown]"
  end

  describe "#type" do
    it "returns the type block_device if it is block device" do
      File.stub :ftype, "blockSpecial" do
        _(connection.file(rand.to_s).type).must_equal :block_device
      end
    end

    it "returns the type character_device if it is character device" do
      File.stub :ftype, "characterSpecial" do
        _(connection.file(rand.to_s).type).must_equal :character_device
      end
    end

    it "returns the type symlink if it is symlink" do
      File.stub :ftype, "link" do
        _(connection.file(rand.to_s).type).must_equal :symlink
      end
    end

    it "returns the type file if it is file" do
      File.stub :ftype, "file" do
        _(connection.file(rand.to_s).type).must_equal :file
      end
    end

    it "returns the type directory if it is block directory" do
      File.stub :ftype, "directory" do
        _(connection.file(rand.to_s).type).must_equal :directory
      end
    end

    it "returns the type pipe if it is pipe" do
      File.stub :ftype, "fifo" do
        _(connection.file(rand.to_s).type).must_equal :pipe
      end
    end

    it "returns the type socket if it is socket" do
      File.stub :ftype, "socket" do
        _(connection.file(rand.to_s).type).must_equal :socket
      end
    end

    it "returns the unknown if not known" do
      File.stub :ftype, "unknown" do
        _(connection.file(rand.to_s).type).must_equal :unknown
      end
    end
  end

  describe "#path" do
    it "returns the path if it is not a symlink" do
      File.stub :symlink?, false do
        filename = rand.to_s
        _(connection.file(filename).path).must_equal filename
      end
    end

    it "returns the link_path if it is a symlink" do
      File.stub :symlink?, true do
        file_obj = connection.file(rand.to_s)
        file_obj.stub :link_path, "/path/to/resolved_link" do
          _(file_obj.path).must_equal "/path/to/resolved_link"
        end
      end
    end
  end

  describe "#link_path" do
    it "returns file's link path" do
      out = rand.to_s
      File.stub :realpath, out do
        File.stub :symlink?, true do
          _(connection.file(rand.to_s).link_path).must_equal out
        end
      end
    end
  end

  describe "#shallow_shlink_path" do
    it "returns file's direct link path" do
      out = rand.to_s
      File.stub :readlink, out do
        File.stub :symlink?, true do
          _(connection.file(rand.to_s).shallow_link_path).must_equal out
        end
      end
    end
  end
end
