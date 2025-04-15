require "helper"
require "train/transports/mock"

class OsDetectWindowsTester
  attr_reader :platform, :backend
  include Train::Platforms::Detect::Helpers::Windows

  def initialize
    @platform = {}
    @backend = Train::Transports::Mock.new.connection
    @backend.mock_os({ family: "windows" })
  end
end

describe "os_detect_windows" do
  describe "windows 2012" do
    let(:detector) do
      detector = OsDetectWindowsTester.new
      detector.backend.mock_command("cmd.exe /c ver", "\r\nMicrosoft Windows [Version 6.3.9600]\r\n", "", 0)
      detector.backend.mock_command("wmic os get * /format:list", "\r\r\nBuildNumber=9600\r\r\nCaption=Microsoft Windows Server 2012 R2 Standard\r\r\nOSArchitecture=64-bit\r\r\nVersion=6.3.9600\r\r\n" , "", 0)
      detector.backend.mock_command("wmic cpu get architecture /format:list", "\r\r\nArchitecture=9\r\r\n" , "", 0)
      detector
    end

    it "sets the correct family/release for windows" do
      detector.detect_windows
      _(detector.platform[:family]).must_equal("windows")
      _(detector.platform[:name]).must_equal("Windows Server 2012 R2 Standard")
      _(detector.platform[:arch]).must_equal("x86_64")
      _(detector.platform[:release]).must_equal("6.3.9600")
    end
  end

  describe "windows 2008" do
    let(:detector) do
      detector = OsDetectWindowsTester.new
      detector.backend.mock_command("cmd.exe /c ver", "\r\nMicrosoft Windows [Version 6.1.7601]\r\n", "", 0)
      detector.backend.mock_command("wmic os get * /format:list", "\r\r\nBuildNumber=7601\r\r\nCaption=Microsoft Windows Server 2008 R2 Standard \r\r\nOSArchitecture=64-bit\r\r\nVersion=6.1.7601\r\r\n" , "", 0)
      detector.backend.mock_command("wmic cpu get architecture /format:list", "\r\r\nArchitecture=9\r\r\n" , "", 0)
      detector
    end

    it "sets the correct family/release for windows" do
      detector.detect_windows
      _(detector.platform[:family]).must_equal("windows")
      _(detector.platform[:name]).must_equal("Windows Server 2008 R2 Standard")
      _(detector.platform[:arch]).must_equal("x86_64")
      _(detector.platform[:release]).must_equal("6.1.7601")
    end
  end

  describe "windows 7" do
    let(:detector) do
      detector = OsDetectWindowsTester.new
      detector.backend.mock_command("cmd.exe /c ver", "\r\nMicrosoft Windows [Version 6.1.7601]\r\n", "", 0)
      detector.backend.mock_command("wmic os get * /format:list", "\r\r\nBuildNumber=7601\r\r\nCaption=Microsoft Windows 7 Enterprise \r\r\nOSArchitecture=32-bit\r\r\nVersion=6.1.7601\r\r\n\r\r\n" , "", 0)
      detector.backend.mock_command("wmic cpu get architecture /format:list", "\r\r\nArchitecture=0\r\r\n" , "", 0)
      detector
    end

    it "sets the correct family/release for windows" do
      detector.detect_windows
      _(detector.platform[:family]).must_equal("windows")
      _(detector.platform[:name]).must_equal("Windows 7 Enterprise")
      _(detector.platform[:arch]).must_equal("i386")
      _(detector.platform[:release]).must_equal("6.1.7601")
    end
  end

  describe "windows 10" do
    let(:detector) do
      detector = OsDetectWindowsTester.new
      detector.backend.mock_command("cmd.exe /c ver", "\r\nMicrosoft Windows [Version 10.0.10240]\r\n", "", 0)
      detector.backend.mock_command("wmic os get * /format:list", "\r\r\nBuildNumber=10240\r\r\nCaption=Microsoft Windows 10 Pro\r\r\nOSArchitecture=64-bit\r\r\nVersion=10.0.10240\r\r\n\r\r\n" , "", 0)
      detector.backend.mock_command("wmic cpu get architecture /format:list", "\r\r\nArchitecture=9\r\r\n" , "", 0)
      detector
    end

    it "sets the correct family/release for windows" do
      detector.detect_windows
      _(detector.platform[:family]).must_equal("windows")
      _(detector.platform[:name]).must_equal("Windows 10 Pro")
      _(detector.platform[:arch]).must_equal("x86_64")
      _(detector.platform[:release]).must_equal("10.0.10240")
    end
  end

  describe "Windows 10 with Powershell" do
    let(:detector) do
      detector = OsDetectWindowsTester.new
      detector.backend.mock_command("Get-WmiObject Win32_OperatingSystem | Select Caption,Version | ConvertTo-Json", "{\"Caption\":\"Microsoft Windows 10 Pro\", \"Version\": \"10.0.18362\"}", "", 0)
      detector.backend.mock_command("wmic os get * /format:list", "\r\r\nBuildNumber=10240\r\r\nCaption=Microsoft Windows 10 Pro\r\r\nOSArchitecture=64-bit\r\r\nVersion=10.0.18362\r\r\n\r\r\n" , "", 0)
      detector.backend.mock_command("wmic cpu get architecture /format:list", "\r\r\nArchitecture=9\r\r\n" , "", 0)
      detector
    end

    it "sets the correct family/release for windows" do
      detector.detect_windows
      _(detector.platform[:family]).must_equal("windows")
      _(detector.platform[:name]).must_equal("Windows 10 Pro")
      _(detector.platform[:arch]).must_equal("x86_64")
      _(detector.platform[:release]).must_equal("10.0.18362")
    end

  end

  describe "windows 98" do
    let(:detector) do
      detector = OsDetectWindowsTester.new
      detector.backend.mock_command("cmd.exe /c ver", "\r\nMicrosoft Windows [Version 4.10.1998]\r\n", "", 0)
      detector.backend.mock_command("wmic os get * /format:list", nil, "", 1)
      detector.backend.mock_command("wmic cpu get architecture /format:list", nil, "", 1)
      detector
    end

    it "fallback to version number if wmic is not available" do
      detector.detect_windows
      _(detector.platform[:family]).must_equal("windows")
      _(detector.platform[:name]).must_equal("Windows 4.10.1998")
      _(detector.platform[:arch]).must_be_nil
      _(detector.platform[:release]).must_equal("4.10.1998")
    end
  end
end

describe "windows_uuid_from_wmic when wmic csproduct get UUID /value returns a valid UUID in stdout" do
  let(:detector) do
    detector = OsDetectWindowsTester.new
    detector.backend.mock_command("wmic csproduct get UUID /value", "\r\r\n\r\r\nUUID=EC20EBD7-8E03-06A8-645F-2D22E5A3BA4B\r\r\n\r\r\n\r\r\n\r\r\n", "", 0)
    detector
  end

  it "retrieves the correct UUID from wmic" do
    _(detector.windows_uuid_from_wmic).must_equal("EC20EBD7-8E03-06A8-645F-2D22E5A3BA4B")
  end
end

describe "windows_uuid_from_wmic when stdout is empty even though wmic csproduct get UUID /value exits successfully" do

  # This is a highly unlikely scenario, but there have been cases where customers
  # observed an empty stdout from `wmic csproduct get UUID` despite a successful exit status.
  # This test case is to ensure that we handle this gracefully.
  # In such cases, we should return nil (which is expected) instead of raising an error.

  let(:detector) do
    detector = OsDetectWindowsTester.new
    detector.backend.mock_command("wmic csproduct get UUID /value", "", "", 0)
    detector
  end

  it "retrieves the correct UUID from wmic" do
    assert_nil(detector.windows_uuid_from_wmic)
  end
end

