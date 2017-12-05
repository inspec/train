# encoding: utf-8
require 'helper'
require 'train/transports/mock'

class OsDetectLinuxTester
  include Train::Platforms::Detect::Helpers::OSCommon
end

describe 'os_detect' do
  let(:detector) { OsDetectLinuxTester.new }

  def scan_with_files(uname, files)
    mock = Train::Transports::Mock::Connection.new
    mock.mock_command('uname -s', uname)
    mock.mock_command('uname -r', 'test-release')
    files.each do |path, data|
      mock.mock_command("test -f #{path}")
      mock.mock_command("test -f #{path} && cat #{path}", data)
    end
    Train::Platforms::Detect.scan(mock)
  end

  ## Detect all linux distros
  describe '/etc/enterprise-release' do
    it 'sets the correct family/release for oracle' do
      path = '/etc/enterprise-release'
      platform = scan_with_files('linux', { path => 'release 7' })

      platform[:name].must_equal('oracle')
      platform[:family].must_equal('redhat')
      platform[:release].must_equal('7')
    end
  end

  describe '/etc/redhat-release' do
    describe 'and /etc/os-release' do
      it 'sets the correct family, name, and release on centos' do
        files = {
          '/etc/redhat-release' => "CentOS Linux release 7.2.1511 (Core) \n",
          '/etc/os-release' => "NAME=\"CentOS Linux\"\nVERSION=\"7 (Core)\"\nID=\"centos\"\nID_LIKE=\"rhel fedora\"\n",
        }
        platform = scan_with_files('linux', files)
        platform[:name].must_equal('centos')
        platform[:family].must_equal('redhat')
        platform[:release].must_equal('7.2.1511')
      end
    end
  end

  describe 'darwin' do
    describe 'mac_os_x' do
      it 'sets the correct family, name, and release on os_x' do
        files = {
          '/System/Library/CoreServices/SystemVersion.plist' => '<string>Mac OS X</string>',
        }
        platform = scan_with_files('darwin', files)
        platform[:name].must_equal('mac_os_x')
        platform[:family].must_equal('darwin')
        platform[:release].must_equal('test-release')
      end
    end

    describe 'generic darwin' do
      it 'sets the correct family, name, and release on darwin' do
        files = {
          '/usr/bin/sw_vers' => "ProductVersion: 17.0.1\nBuildVersion: alpha.x1",
        }
        platform = scan_with_files('darwin', files)
        platform[:name].must_equal('darwin')
        platform[:family].must_equal('darwin')
        platform[:release].must_equal('17.0.1')
        platform[:build].must_equal('alpha.x1')
      end
    end
  end

  describe '/etc/debian_version' do
    def debian_scan(id, version)
      lsb_release = "DISTRIB_ID=#{id}\nDISTRIB_RELEASE=#{version}"
      files = {
        '/etc/lsb-release' => lsb_release,
        '/etc/debian_version' => '11',
      }
      scan_with_files('linux', files)
    end

    describe 'ubuntu' do
      it 'sets the correct family/release for ubuntu' do
        platform = debian_scan('ubuntu', '16.04')

        platform[:name].must_equal('ubuntu')
        platform[:family].must_equal('debian')
        platform[:release].must_equal('16.04')
      end
    end

    describe 'linuxmint' do
      it 'sets the correct family/release for linuxmint' do
        platform = debian_scan('linuxmint', '12')

        platform[:name].must_equal('linuxmint')
        platform[:family].must_equal('debian')
        platform[:release].must_equal('12')
      end
    end

    describe 'raspbian' do
      it 'sets the correct family/release for raspbian ' do
        files = {
          '/usr/bin/raspi-config' => 'data',
          '/etc/debian_version' => '13.6',
        }
        platform = scan_with_files('linux', files)

        platform[:name].must_equal('raspbian')
        platform[:family].must_equal('debian')
        platform[:release].must_equal('13.6')
      end
    end

    describe 'everything else' do
      it 'sets the correct family/release for debian ' do
        platform = debian_scan('some_debian', '12.99')

        platform[:name].must_equal('debian')
        platform[:family].must_equal('debian')
        platform[:release].must_equal('11')
      end
    end
  end

  describe '/etc/coreos/update.conf' do
    it 'sets the correct family/release for coreos' do
      lsb_release = "DISTRIB_ID=Container Linux by CoreOS\nDISTRIB_RELEASE=27.9"
      files = {
        '/etc/lsb-release' => lsb_release,
        '/etc/coreos/update.conf' => 'data',
      }
      platform = scan_with_files('linux', files)

      platform[:name].must_equal('coreos')
      platform[:family].must_equal('linux')
      platform[:release].must_equal('27.9')
    end
  end

  describe '/etc/os-release' do
    describe 'when not on a wrlinux build' do
      it 'fail back to genaric linux' do
        os_release = "ID_LIKE=cisco-unkwown\nVERSION=unknown"
        files = {
          '/etc/os-release' => os_release,
        }
        platform = scan_with_files('linux', files)

        platform[:name].must_equal('linux')
        platform[:family].must_equal('linux')
      end
    end

    describe 'when on a wrlinux build' do
      it 'sets the correct family/release for wrlinux' do
        os_release = "ID_LIKE=cisco-wrlinux\nVERSION=cisco123"
        files = {
          '/etc/os-release' => os_release,
        }
        platform = scan_with_files('linux', files)

        platform[:name].must_equal('wrlinux')
        platform[:family].must_equal('redhat')
        platform[:release].must_equal('cisco123')
      end
    end
  end
end
