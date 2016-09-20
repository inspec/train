require 'train/extras'

class OsDetectWindowsTester
  attr_reader :platform, :backend
  include Train::Extras::DetectWindows

  def initialize
    @platform = {}
    @backend = Train::Transports::Mock.new.connection
    @backend.mock_os({ family: 'windows' })
  end
end

describe 'os_detect_windows' do
  describe 'windows 2012' do
    let(:detector) {
      detector = OsDetectWindowsTester.new
      detector.backend.mock_command('cmd /c ver', "\r\nMicrosoft Windows [Version 6.3.9600]\r\n", '', 0)
      detector.backend.mock_command('wmic os get * /format:list',"\r\r\nBuildNumber=9600\r\r\nCaption=Microsoft Windows Server 2012 R2 Standard\r\r\nOSArchitecture=64-bit\r\r\nVersion=6.3.9600\r\r\n" , '', 0)
      detector.backend.mock_command('wmic cpu get architecture /format:list',"\r\r\nArchitecture=9\r\r\n" , '', 0)
      detector
    }

    it 'sets the correct family/release for windows' do
      detector.detect_windows
      detector.platform[:family].must_equal('windows')
      detector.platform[:name].must_equal('Windows Server 2012 R2 Standard')
      detector.platform[:arch].must_equal('x86_64')
      detector.platform[:release].must_equal('6.3.9600')
    end
  end

  describe 'windows 2008' do
    let(:detector) {
      detector = OsDetectWindowsTester.new
      detector.backend.mock_command('cmd /c ver', "\r\nMicrosoft Windows [Version 6.1.7601]\r\n", '', 0)
      detector.backend.mock_command('wmic os get * /format:list',"\r\r\nBuildNumber=7601\r\r\nCaption=Microsoft Windows Server 2008 R2 Standard \r\r\nOSArchitecture=64-bit\r\r\nVersion=6.1.7601\r\r\n" , '', 0)
      detector.backend.mock_command('wmic cpu get architecture /format:list',"\r\r\nArchitecture=9\r\r\n" , '', 0)
      detector
    }

    it 'sets the correct family/release for windows' do
      detector.detect_windows
      detector.platform[:family].must_equal('windows')
      detector.platform[:name].must_equal('Windows Server 2008 R2 Standard')
      detector.platform[:arch].must_equal('x86_64')
      detector.platform[:release].must_equal('6.1.7601')
    end
  end

  describe 'windows 7' do
    let(:detector) {
      detector = OsDetectWindowsTester.new
      detector.backend.mock_command('cmd /c ver', "\r\nMicrosoft Windows [Version 6.1.7601]\r\n", '', 0)
      detector.backend.mock_command('wmic os get * /format:list',"\r\r\nBuildNumber=7601\r\r\nCaption=Microsoft Windows 7 Enterprise \r\r\nOSArchitecture=32-bit\r\r\nVersion=6.1.7601\r\r\n\r\r\n" , '', 0)
      detector.backend.mock_command('wmic cpu get architecture /format:list',"\r\r\nArchitecture=0\r\r\n" , '', 0)
      detector
    }

    it 'sets the correct family/release for windows' do
      detector.detect_windows
      detector.platform[:family].must_equal('windows')
      detector.platform[:name].must_equal('Windows 7 Enterprise')
      detector.platform[:arch].must_equal('i386')
      detector.platform[:release].must_equal('6.1.7601')
    end
  end

  describe 'windows 10' do
    let(:detector) {
      detector = OsDetectWindowsTester.new
      detector.backend.mock_command('cmd /c ver', "\r\nMicrosoft Windows [Version 10.0.10240]\r\n", '', 0)
      detector.backend.mock_command('wmic os get * /format:list',"\r\r\nBuildNumber=10240\r\r\nCaption=Microsoft Windows 10 Pro\r\r\nOSArchitecture=64-bit\r\r\nVersion=10.0.10240\r\r\n\r\r\n" , '', 0)
      detector.backend.mock_command('wmic cpu get architecture /format:list',"\r\r\nArchitecture=9\r\r\n" , '', 0)
      detector
    }

    it 'sets the correct family/release for windows' do
      detector.detect_windows
      detector.platform[:family].must_equal('windows')
      detector.platform[:name].must_equal('Windows 10 Pro')
      detector.platform[:arch].must_equal('x86_64')
      detector.platform[:release].must_equal('10.0.10240')
    end
  end

  describe 'windows 98' do
    let(:detector) {
      detector = OsDetectWindowsTester.new
      detector.backend.mock_command('cmd /c ver', "\r\nMicrosoft Windows [Version 4.10.1998]\r\n", '', 0)
      detector.backend.mock_command('wmic os get * /format:list', nil, '', 1)
      detector.backend.mock_command('wmic cpu get architecture /format:list', nil, '', 1)
      detector
    }

    it 'fallback to version number if wmic is not available' do
      detector.detect_windows
      detector.platform[:family].must_equal('windows')
      detector.platform[:name].must_equal('Windows 4.10.1998')
      detector.platform[:arch].must_equal(nil)
      detector.platform[:release].must_equal('4.10.1998')
    end
  end
end
