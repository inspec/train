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
      detector.backend.mock_command("wmic /?", "", "", 0) # Mock wmic availability
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
      detector.backend.mock_command("wmic /?", "", "", 0) # Mock wmic availability
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
      detector.backend.mock_command("wmic /?", "", "", 0) # Mock wmic availability
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
      detector.backend.mock_command("wmic /?", "", "", 0) # Mock wmic availability
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
      detector.backend.mock_command("wmic /?", "", "", 0) # Mocking wmic command to simulate its availability
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
      detector.backend.mock_command("wmic /?", "", "", 1) # Mock wmic not available
      detector.backend.mock_command("wmic os get * /format:list", nil, "", 1)
      detector.backend.mock_command("wmic cpu get architecture /format:list", nil, "", 1)
      # Mock fallback commands for read_cmd_os
      detector.backend.mock_command("echo %PROCESSOR_ARCHITECTURE%", "x86", "", 0)
      detector.backend.mock_command("systeminfo", "", "", 1) # systeminfo might not work on win98
      detector
    end

    it "fallback to version number if wmic is not available" do
      detector.detect_windows
      _(detector.platform[:family]).must_equal("windows")
      _(detector.platform[:name]).must_equal("Windows 4.10.1998")
      _(detector.platform[:arch]).must_equal("i386") # Now set by read_cmd_os fallback
      _(detector.platform[:release]).must_equal("4.10.1998")
    end
  end
end

describe "wmic_available?" do
  let(:detector) do
    detector = OsDetectWindowsTester.new
    detector.backend.mock_command("wmic /?", "", "", 0)
    detector
  end

  it "returns true if wmic is available" do
    _(detector.wmic_available?).must_equal(true)
  end

  it "returns false if wmic is not available" do
    detector.backend.mock_command("wmic /?", "", "", 1)
    _(detector.wmic_available?).must_equal(false)
  end

  it "returns false if wmic is available but is deprecated" do
    detector.backend.mock_command("wmic /?", "WMIC is deprecated", "", 0)
    _(detector.wmic_available?).must_equal(false)
  end
end

describe "windows_uuid_from_cim" do
  let(:detector) do
    detector = OsDetectWindowsTester.new
    detector.backend.mock_command('powershell -Command "(Get-CimInstance -Class Win32_ComputerSystemProduct).UUID"', "EC20EBD7-8E03-06A8-645F-2D22E5A3BA4B", "", 0)
    detector
  end

  it "retrieves the correct UUID from CIM" do
    _(detector.windows_uuid_from_cim).must_equal("EC20EBD7-8E03-06A8-645F-2D22E5A3BA4B")
  end

  it "returns nil if the command fails" do
    detector.backend.mock_command('powershell -Command "(Get-CimInstance -Class Win32_ComputerSystemProduct).UUID"', "", "", 1)
    assert_nil(detector.windows_uuid_from_cim)
  end
end

describe "read_cim_cpu" do
  let(:detector) do
    detector = OsDetectWindowsTester.new
    detector.backend.mock_command('powershell -Command "(Get-CimInstance Win32_Processor).Architecture"', "9", "", 0)
    detector
  end

  it "retrieves the correct architecture from CIM" do
    _(detector.read_cim_cpu).must_equal("x86_64")
  end

  it "returns nil if the command fails" do
    detector.backend.mock_command('powershell -Command "(Get-CimInstance Win32_Processor).Architecture"', "", "", 1)
    assert_nil(detector.read_cim_cpu)
  end
end

describe "read_cim_os" do
  let(:detector) do
    detector = OsDetectWindowsTester.new
    detector.backend.mock_command('powershell -Command "Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber | ConvertTo-Json"', "{\"Caption\":\"Microsoft Windows 11\", \"Version\": \"10.0.26100\", \"BuildNumber\": \"18362\"}", "", 0)
    detector.backend.mock_command('powershell -Command "(Get-CimInstance Win32_Processor).Architecture"', "9", "", 0)
    detector
  end

  it "retrieves the correct OS information from CIM" do
    detector.read_cim_os
    _(detector.platform[:name]).must_equal("Windows 11")
    _(detector.platform[:release]).must_equal("10.0.26100")
    _(detector.platform[:build]).must_equal("18362")
    _(detector.platform[:arch]).must_equal("x86_64")
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

describe "read_cmd_os" do
  describe "when wmic is not available" do
    let(:detector) do
      detector = OsDetectWindowsTester.new
      detector.backend.mock_command("echo %PROCESSOR_ARCHITECTURE%", "AMD64", "", 0)
      detector.backend.mock_command("systeminfo", "OS Name:                   Microsoft Windows 10 Pro\r\nOS Version:                10.0.19044 N/A Build 19044\r\n", "", 0)
      detector
    end

    it "retrieves architecture from PROCESSOR_ARCHITECTURE environment variable" do
      detector.read_cmd_os
      _(detector.platform[:arch]).must_equal("x86_64")
    end

    it "retrieves OS info from systeminfo command" do
      detector.read_cmd_os
      _(detector.platform[:name]).must_equal("Windows 10 Pro")
      _(detector.platform[:release]).must_equal("10.0.19044")
      _(detector.platform[:build]).must_equal("19044")
    end
  end

  describe "with x86 architecture" do
    let(:detector) do
      detector = OsDetectWindowsTester.new
      detector.backend.mock_command("echo %PROCESSOR_ARCHITECTURE%", "x86", "", 0)
      detector.backend.mock_command("systeminfo", "", "", 0)
      detector
    end

    it "maps x86 to i386" do
      detector.read_cmd_os
      _(detector.platform[:arch]).must_equal("i386")
    end
  end

  describe "with ARM64 architecture" do
    let(:detector) do
      detector = OsDetectWindowsTester.new
      detector.backend.mock_command("echo %PROCESSOR_ARCHITECTURE%", "ARM64", "", 0)
      detector.backend.mock_command("systeminfo", "", "", 0)
      detector
    end

    it "maps ARM64 correctly" do
      detector.read_cmd_os
      _(detector.platform[:arch]).must_equal("arm64")
    end
  end

  describe "when environment variable command fails" do
    let(:detector) do
      detector = OsDetectWindowsTester.new
      detector.backend.mock_command("echo %PROCESSOR_ARCHITECTURE%", "", "", 1)
      detector.backend.mock_command("systeminfo", "", "", 0)
      detector
    end

    it "sets architecture to nil explicitly" do
      detector.read_cmd_os
      _(detector.platform[:arch]).must_be_nil
    end
  end

  describe "when systeminfo command fails" do
    let(:detector) do
      detector = OsDetectWindowsTester.new
      detector.backend.mock_command("echo %PROCESSOR_ARCHITECTURE%", "AMD64", "", 0)
      detector.backend.mock_command("systeminfo", "", "", 1)
      detector
    end

    it "sets architecture but not OS details" do
      detector.read_cmd_os
      _(detector.platform[:arch]).must_equal("x86_64")
      _(detector.platform[:name]).must_be_nil
      _(detector.platform[:release]).must_be_nil
      _(detector.platform[:build]).must_be_nil
    end
  end
end

describe "check_cmd fallback behavior" do
  describe "when wmic is deprecated" do
    let(:detector) do
      detector = OsDetectWindowsTester.new
      detector.backend.mock_command("cmd.exe /c ver", "\r\nMicrosoft Windows [Version 10.0.19044]\r\n", "", 0)
      detector.backend.mock_command("wmic /?", "WMIC is deprecated", "", 0)
      detector.backend.mock_command("echo %PROCESSOR_ARCHITECTURE%", "AMD64", "", 0)
      detector.backend.mock_command("systeminfo", "OS Name:                   Microsoft Windows 10 Pro\r\nOS Version:                10.0.19044 N/A Build 19044\r\n", "", 0)
      detector
    end

    it "uses read_cmd_os fallback instead of read_wmic" do
      detector.check_cmd
      _(detector.platform[:family]).must_equal("windows")
      _(detector.platform[:arch]).must_equal("x86_64")
      _(detector.platform[:name]).must_equal("Windows 10 Pro")
      _(detector.platform[:release]).must_equal("10.0.19044")
      _(detector.platform[:build]).must_equal("19044")
    end
  end

  describe "when wmic is not available" do
    let(:detector) do
      detector = OsDetectWindowsTester.new
      detector.backend.mock_command("cmd.exe /c ver", "\r\nMicrosoft Windows [Version 10.0.19044]\r\n", "", 0)
      detector.backend.mock_command("wmic /?", "", "", 1)
      detector.backend.mock_command("echo %PROCESSOR_ARCHITECTURE%", "AMD64", "", 0)
      detector.backend.mock_command("systeminfo", "OS Name:                   Microsoft Windows 10 Pro\r\nOS Version:                10.0.19044 N/A Build 19044\r\n", "", 0)
      detector
    end

    it "uses read_cmd_os fallback instead of read_wmic" do
      detector.check_cmd
      _(detector.platform[:family]).must_equal("windows")
      _(detector.platform[:arch]).must_equal("x86_64")
      _(detector.platform[:name]).must_equal("Windows 10 Pro")
      _(detector.platform[:release]).must_equal("10.0.19044")
      _(detector.platform[:build]).must_equal("19044")
    end
  end
end

