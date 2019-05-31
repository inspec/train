require "helper"
require "train/transports/local"
require "train/file/remote/aix"
require "train/transports/mock"

describe Train::File::Remote::Aix do
  let(:cls) { Train::File::Remote::Aix }
  let(:backend) do
    backend = Train::Transports::Mock.new.connection
    backend.mock_os({ name: "aix", family: "unix" })
    backend
  end

  it "returns a nil link_path if the object is not a symlink" do
    file = cls.new(backend, "path")
    file.stubs(:symlink?).returns(false)
    file.link_path.must_be_nil
  end

  it "returns a correct link_path" do
    file = cls.new(backend, "path")
    file.stubs(:symlink?).returns(true)
    backend.mock_command("perl -e 'print readlink shift' path", "our_link_path")
    file.link_path.must_equal "our_link_path"
  end

  it "returns a correct shallow_link_path" do
    file = cls.new(backend, "path")
    file.stubs(:symlink?).returns(true)
    backend.mock_command("perl -e 'print readlink shift' path", "our_link_path")
    file.link_path.must_equal "our_link_path"
  end

  describe "#md5sum" do
    let(:md5_checksum) { "57d4c6f9d15313fd5651317e588c035d" }

    let(:ruby_md5_mock) do
      checksum_mock = mock
      checksum_mock.expects(:update).returns("")
      checksum_mock.expects(:hexdigest).returns(md5_checksum)
      checksum_mock
    end

    it "defaults to a Ruby based checksum if other methods fail" do
      backend.mock_command("md5sum /tmp/testfile", "", "", 1)
      Digest::MD5.expects(:new).returns(ruby_md5_mock)
      cls.new(backend, "/tmp/testfile").md5sum.must_equal md5_checksum
    end

    it "calculates the correct md5sum on the `aix` platform family" do
      output = "#{md5_checksum} /tmp/testfile"
      backend.mock_command("md5sum /tmp/testfile", output)
      cls.new(backend, "/tmp/testfile").md5sum.must_equal md5_checksum
    end
  end

  describe "#sha256sum" do
    let(:sha256_checksum) do
      "491260aaa6638d4a64c714a17828c3d82bad6ca600c9149b3b3350e91bcd283d"
    end

    let(:ruby_sha256_mock) do
      checksum_mock = mock
      checksum_mock.expects(:update).returns("")
      checksum_mock.expects(:hexdigest).returns(sha256_checksum)
      checksum_mock
    end

    it "defaults to a Ruby based checksum if other methods fail" do
      backend.mock_command("sha256sum /tmp/testfile", "", "", 1)
      Digest::SHA256.expects(:new).returns(ruby_sha256_mock)
      cls.new(backend, "/tmp/testfile").sha256sum.must_equal sha256_checksum
    end

    it "calculates the correct sha256sum on the `aix` platform family" do
      output = "#{sha256_checksum} /tmp/testfile"
      backend.mock_command("sha256sum /tmp/testfile", output)
      cls.new(backend, "/tmp/testfile").sha256sum.must_equal sha256_checksum
    end
  end
end
