# encoding: utf-8

require "helper"

class OsDetectLinuxTester
  attr_reader :platform
  include Train::Platforms::Detect::Helpers::OSCommon

  def initialize
    @platform = {}
  end
end

describe "os_common" do
  let(:detector) { OsDetectLinuxTester.new }

  describe "winrm? check" do
    it "return winrm? true" do
      require "train/transports/winrm"
      be = Train::Transports::WinRM::Connection.new(nil)
      detector.instance_variable_set(:@backend, be)
      detector.winrm?.must_equal(true)
    end

    it "return winrm? false when winrm is loaded" do
      require "train/transports/winrm"
      be = mock("Backend")
      detector.instance_variable_set(:@backend, be)
      detector.winrm?.must_equal(false)
    end

    it "return winrm? false when winrm is not loaded" do
      require "train/transports/winrm"
      winrm = Train::Transports.send(:remove_const, "WinRM")
      be = mock("Backend")
      detector.instance_variable_set(:@backend, be)
      detector.winrm?.must_equal(false)
      Train::Transports.const_set("WinRM", winrm)
    end
  end

  describe "unix file contents" do
    it "return new file contents" do
      be = mock("Backend")
      output = mock("Output", exit_status: 0)
      output.expects(:stdout).returns("test")
      be.stubs(:run_command).with("test -f /etc/fstab && cat /etc/fstab").returns(output)
      detector.instance_variable_set(:@backend, be)
      detector.instance_variable_set(:@files, {})
      detector.unix_file_contents("/etc/fstab").must_equal("test")
    end

    it "return new file contents cached" do
      be = mock("Backend")
      detector.instance_variable_set(:@backend, be)
      detector.instance_variable_set(:@files, { "/etc/profile" => "test" })
      detector.unix_file_contents("/etc/profile").must_equal("test")
    end
  end

  describe "unix file exist?" do
    it "file does exist" do
      be = mock("Backend")
      be.stubs(:run_command).with("test -f /etc/test").returns(mock("Output", exit_status: 0))
      detector.instance_variable_set(:@backend, be)
      detector.unix_file_exist?("/etc/test").must_equal(true)
    end
  end

  describe "#detect_linux_arch" do
    it "uname m call" do
      be = mock("Backend")
      be.stubs(:run_command).with("uname -m").returns(mock("Output", stdout: "x86_64\n"))
      detector.instance_variable_set(:@backend, be)
      detector.instance_variable_set(:@uname, {})
      detector.unix_uname_m.must_equal("x86_64")
    end

    it "uname s call" do
      be = mock("Backend")
      be.stubs(:run_command).with("uname -s").returns(mock("Output", stdout: "linux"))
      detector.instance_variable_set(:@backend, be)
      detector.instance_variable_set(:@uname, {})
      detector.unix_uname_s.must_equal("linux")
    end

    it "uname r call" do
      be = mock("Backend")
      be.stubs(:run_command).with("uname -r").returns(mock("Output", stdout: "17.0.0\n"))
      detector.instance_variable_set(:@backend, be)
      detector.instance_variable_set(:@uname, {})
      detector.unix_uname_r.must_equal("17.0.0")
    end
  end
end
