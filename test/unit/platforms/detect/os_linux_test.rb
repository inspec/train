require "helper"
require "train/transports/mock"

class OsDetectLinuxTester
  include Train::Platforms::Detect::Helpers::OSCommon
end

describe "os_linux" do
  let(:detector) { OsDetectLinuxTester.new }

  describe "redhatish_platform cleaner" do
    it "normal redhat" do
      _(detector.redhatish_platform("Red Hattter")).must_equal("redhat")
    end

    it "custom redhat" do
      _(detector.redhatish_platform("Centos Pro 11")).must_equal("centos")
    end
  end

  describe "redhatish_version cleaner" do
    it "normal rawhide" do
      _(detector.redhatish_version("18 (Rawhide) Pro")).must_equal("18 (rawhide)")
    end

    it "normal linux" do
      _(detector.redhatish_version("derived from Ubuntu Linux 11")).must_equal("11")
    end

    it "amazon linux 2 new release naming schema" do
      _(detector.redhatish_version("Amazon Linux release 2 (Karoo)")).must_equal("2")
    end

    it "amazon linux 2 old release naming schema" do
      _(detector.redhatish_version("Amazon Linux 2")).must_equal("2")
    end
  end

  describe "lsb parse" do
    it "lsb config" do
      lsb = "DISTRIB_ID=Ubuntu\nDISTRIB_RELEASE=14.06\nDISTRIB_CODENAME=xenial"
      expect = { id: "Ubuntu", release: "14.06", codename: "xenial" }
      _(detector.lsb_config(lsb)).must_equal(expect)
    end

    it "lsb releasel" do
      lsb = "Distributor ID: Ubuntu\nRelease: 14.06\nCodename: xenial"
      expect = { id: "Ubuntu", release: "14.06", codename: "xenial" }
      _(detector.lsb_release(lsb)).must_equal(expect)
    end
  end

  describe "#linux_os_release" do
    describe "when no os-release data is available" do
      it "returns nil" do
        detector.expects(:unix_file_contents).with("/etc/os-release").returns(nil)
        _(detector.linux_os_release).must_be_nil
      end
    end
  end

  describe "when os-release data exists with no CISCO_RELEASE_INFO" do
    let(:os_release) { { "KEY1" => "VALUE1" } }

    it "returns a correct hash" do
      detector.expects(:unix_file_contents).with("/etc/os-release").returns("os-release data")
      detector.expects(:parse_os_release_info).with("os-release data").returns(os_release)
      _(detector.linux_os_release["KEY1"]).must_equal("VALUE1")
    end
  end

  describe "when os-release data exists with CISCO_RELEASE_INFO" do
    let(:os_release)    { { "KEY1" => "VALUE1", "CISCO_RELEASE_INFO" => "cisco_file" } }
    let(:cisco_release) { { "KEY1" => "NEWVALUE1", "KEY2" => "VALUE2" } }

    it "returns a correct hash" do
      detector.expects(:unix_file_contents).with("/etc/os-release").returns("os-release data")
      detector.expects(:unix_file_contents).with("cisco_file").returns("cisco data")
      detector.expects(:parse_os_release_info).with("os-release data").returns(os_release)
      detector.expects(:parse_os_release_info).with("cisco data").returns(cisco_release)

      os_info = detector.linux_os_release
      _(os_info["KEY1"]).must_equal("NEWVALUE1")
      _(os_info["KEY2"]).must_equal("VALUE2")
    end
  end

  describe "#parse_os_release_info" do
    describe "when nil is supplied" do
      it "returns an empty hash" do
        _(detector.parse_os_release_info(nil)).must_equal({})
      end
    end

    describe "when unexpectedly-formatted data is supplied" do
      let(:data) do
        <<~EOL
          blah blah
          no good data here
        EOL
      end

      it "returns an empty hash" do
        _(detector.parse_os_release_info(nil)).must_equal({})
      end
    end

    describe "when properly-formatted data is supplied" do
      let(:data) do
        <<~EOL
          KEY1=value1
          KEY2=
          KEY3=value3
          KEY4="value4 with spaces"
          KEY5="value5 with a = sign"
        EOL
      end

      it "parses the data correctly" do
        parsed_data = detector.parse_os_release_info(data)

        _(parsed_data["KEY1"]).must_equal("value1")
        _(parsed_data.key?("KEY2")).must_equal(false)
        _(parsed_data["KEY3"]).must_equal("value3")
        _(parsed_data["KEY4"]).must_equal("value4 with spaces")
        _(parsed_data["KEY5"]).must_equal("value5 with a = sign")
      end
    end
  end
end
