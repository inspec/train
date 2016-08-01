# encoding: utf-8
require 'helper'
require 'train/extras'

class OsDetectLinuxTester
  attr_reader :platform
  include Train::Extras::DetectLinux

  def initialize
    @platform = {}
  end
end

describe 'os_detect_linux' do
  let(:detector) { OsDetectLinuxTester.new }

  describe '#detect_linux_arch' do
    it "sets the arch using uname" do
      be = mock("Backend")
      detector.stubs(:backend).returns(be)
      be.stubs(:run_command).with("uname -m").returns(mock("Output", stdout: "x86_64\n"))
      detector.detect_linux_arch
      detector.platform[:arch].must_equal("x86_64")
    end
  end

  describe '#detect_linux_via_config' do

    before do
      detector.stubs(:get_config)
      detector.stubs(:fetch_os_release)
      detector.stubs(:redhatish_version).returns('redhat-version')
    end

    describe '/etc/enterprise-release' do
      it 'sets the correct family/release for oracle' do
        detector.stubs(:get_config).with('/etc/enterprise-release').returns('data')

        detector.detect_linux_via_config.must_equal(true)
        detector.platform[:name].must_equal('oracle')
        detector.platform[:family].must_equal('redhat')
        detector.platform[:release].must_equal('redhat-version')
      end
    end

    describe "/etc/redhat-release" do
      describe "and /etc/os-release" do
        it "sets the correct family, name, and release on centos" do
          detector.stubs(:get_config).with("/etc/redhat-release").returns("CentOS Linux release 7.2.1511 (Core) \n")
          detector.stubs(:get_config).with("/etc/os-release").returns("NAME=\"CentOS Linux\"\nVERSION=\"7 (Core)\"\nID=\"centos\"\nID_LIKE=\"rhel fedora\"\n")
          detector.detect_linux_via_config.must_equal(true)
          detector.platform[:name].must_equal('centos')
          detector.platform[:family].must_equal('redhat')
          detector.platform[:release].must_equal('redhat-version')
        end
      end
    end

    describe '/etc/debian_version' do

      before { detector.stubs(:get_config).with('/etc/debian_version').returns('deb-version') }

      describe 'ubuntu' do
        it 'sets the correct family/release for ubuntu' do
          detector.stubs(:lsb).returns({ id: 'ubuntu', release: 'ubuntu-release' })

          detector.detect_linux_via_config.must_equal(true)
          detector.platform[:name].must_equal('ubuntu')
          detector.platform[:family].must_equal('debian')
          detector.platform[:release].must_equal('ubuntu-release')
        end
      end

      describe 'linuxmint' do
        it 'sets the correct family/release for ubuntu' do
          detector.stubs(:lsb).returns({ id: 'linuxmint', release: 'mint-release' })

          detector.detect_linux_via_config.must_equal(true)
          detector.platform[:name].must_equal('linuxmint')
          detector.platform[:family].must_equal('debian')
          detector.platform[:release].must_equal('mint-release')
        end
      end

      describe 'raspbian' do
        it 'sets the correct family/release for raspbian ' do
          detector.stubs(:lsb).returns({ id: 'something_else', release: 'some_release' })
          detector.expects(:unix_file?).with('/usr/bin/raspi-config').returns(true)

          detector.detect_linux_via_config.must_equal(true)
          detector.platform[:name].must_equal('raspbian')
          detector.platform[:family].must_equal('debian')
          detector.platform[:release].must_equal('deb-version')
        end
      end

      describe 'everything else' do
        it 'sets the correct family/release for debian ' do
          detector.stubs(:lsb).returns({ id: 'something_else', release: 'some_release' })
          detector.expects(:unix_file?).with('/usr/bin/raspi-config').returns(false)

          detector.detect_linux_via_config.must_equal(true)
          detector.platform[:name].must_equal('debian')
          detector.platform[:family].must_equal('debian')
          detector.platform[:release].must_equal('deb-version')
        end
      end
    end

    describe '/etc/os-release' do
      describe 'when not on a wrlinux build' do
        it 'does not set a platform family/release' do
          detector.stubs(:fetch_os_release).returns({ 'ID_LIKE' => 'something_else' })

          detector.detect_linux_via_config.must_equal(false)
          detector.platform[:family].must_equal(nil)
          detector.platform[:release].must_equal(nil)
        end
      end

      describe 'when on a wrlinux build' do
        let(:data) do
          {
            'ID_LIKE' => 'cisco-wrlinux',
            'VERSION' => 'cisco123'
          }
        end

        it 'sets the correct family/release for wrlinux' do
          detector.stubs(:fetch_os_release).returns(data)

          detector.detect_linux_via_config.must_equal(true)
          detector.platform[:name].must_equal('wrlinux')
          detector.platform[:family].must_equal('redhat')
          detector.platform[:release].must_equal('cisco123')
        end
      end
    end
  end

  describe '#fetch_os_release' do
    describe 'when no os-release data is available' do
      it 'returns nil' do
        detector.expects(:get_config).with('/etc/os-release').returns(nil)
        detector.fetch_os_release.must_equal(nil)
      end
    end

    describe 'when os-release data exists with no CISCO_RELEASE_INFO' do
      let(:os_release) { { 'KEY1' => 'VALUE1' } }

      it 'returns a correct hash' do
        detector.expects(:get_config).with('/etc/os-release').returns('os-release data')
        detector.expects(:parse_os_release_info).with('os-release data').returns(os_release)
        detector.fetch_os_release['KEY1'].must_equal('VALUE1')
      end
    end

    describe 'when os-release data exists with CISCO_RELEASE_INFO' do
      let(:os_release)    { { 'KEY1' => 'VALUE1', 'CISCO_RELEASE_INFO' => 'cisco_file' } }
      let(:cisco_release) { { 'KEY1' => 'NEWVALUE1', 'KEY2' => 'VALUE2' } }

      it 'returns a correct hash' do
        detector.expects(:get_config).with('/etc/os-release').returns('os-release data')
        detector.expects(:get_config).with('cisco_file').returns('cisco data')
        detector.expects(:parse_os_release_info).with('os-release data').returns(os_release)
        detector.expects(:parse_os_release_info).with('cisco data').returns(cisco_release)

        os_info = detector.fetch_os_release
        os_info['KEY1'].must_equal('NEWVALUE1')
        os_info['KEY2'].must_equal('VALUE2')
      end
    end
  end

  describe '#parse_os_release_info' do
    describe 'when nil is supplied' do
      it 'returns an empty hash' do
        detector.parse_os_release_info(nil).must_equal({})
      end
    end

    describe 'when unexpectedly-formatted data is supplied' do
      let(:data) do
        <<-EOL
blah blah
no good data here
        EOL
      end

      it 'returns an empty hash' do
        detector.parse_os_release_info(nil).must_equal({})
      end
    end

    describe 'when properly-formatted data is supplied' do
      let(:data) do
        <<-EOL
KEY1=value1
KEY2=
KEY3=value3
KEY4="value4 with spaces"
KEY5="value5 with a = sign"
        EOL
      end

      it 'parses the data correctly' do
        parsed_data = detector.parse_os_release_info(data)

        parsed_data['KEY1'].must_equal('value1')
        parsed_data.key?('KEY2').must_equal(false)
        parsed_data['KEY3'].must_equal('value3')
        parsed_data['KEY4'].must_equal('value4 with spaces')
        parsed_data['KEY5'].must_equal('value5 with a = sign')
      end
    end
  end
end
