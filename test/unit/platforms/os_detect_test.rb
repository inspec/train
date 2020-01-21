# encoding: utf-8
require "helper"
require "train/transports/mock"

class OsDetectTester
  include Train::Platforms::Detect::Helpers::OSCommon
end

describe "os_detect" do
  let(:detector) { OsDetectTester.new }

  def scan_with_files(uname, files)
    mock = Train::Transports::Mock::Connection.new
    mock.mock_command("uname -s", uname)
    mock.mock_command("uname -r", "test-release")
    files.each do |path, data|
      mock.mock_command("test -f #{path}")
      mock.mock_command("test -f #{path} && cat #{path}", data)
    end
    Train::Platforms::Detect.scan(mock)
  end

  def scan_with_windows
    mock = Train::Transports::Mock::Connection.new
    mock.mock_command("cmd.exe /c ver", "Microsoft Windows [Version 6.3.9600]")
    Train::Platforms::Detect.scan(mock)
  end

  ## Detect all linux distros
  describe "/etc/enterprise-release" do
    it "sets the correct family/release for oracle" do
      path = "/etc/enterprise-release"
      platform = scan_with_files("linux", { path => "release 7" })

      _(platform[:name]).must_equal("oracle")
      _(platform[:family]).must_equal("redhat")
      _(platform[:release]).must_equal("7")
    end
  end

  describe "/etc/redhat-release" do
    describe "and /etc/os-release" do
      it "sets the correct family, name, and release on centos" do
        files = {
          "/etc/redhat-release" => "CentOS Linux release 7.2.1511 (Core) \n",
          "/etc/os-release" => "NAME=\"CentOS Linux\"\nVERSION=\"7 (Core)\"\nID=\"centos\"\nID_LIKE=\"rhel fedora\"\n",
        }
        platform = scan_with_files("linux", files)
        _(platform[:name]).must_equal("centos")
        _(platform[:family]).must_equal("redhat")
        _(platform[:release]).must_equal("7.2.1511")
      end
      it "sets the correct family, name, and release on scientific linux" do
        files = {
          "/etc/redhat-release" => "Scientific Linux release 7.4 (Nitrogen)\n",
          "/etc/os-release" => "NAME=\"Scientific Linux\"\nVERSION=\"7.4 (Nitrogen)\"\nID=\"rhel\"\nID_LIKE=\"scientific centos fedora\"\nVERSION_ID=\"7.4\"\nPRETTY_NAME=\"Scientific Linux 7.4 (Nitrogen)\"\nANSI_COLOR=\"0;31\"\nCPE_NAME=\"cpe:/o:scientificlinux:scientificlinux:7.4:GA\"\nHOME_URL=\"http://www.scientificlinux.org//\"\nBUG_REPORT_URL=\"mailto:scientific-linux-devel@listserv.fnal.gov\"\n\nREDHAT_BUGZILLA_PRODUCT=\"Scientific Linux 7\"\nREDHAT_BUGZILLA_PRODUCT_VERSION=7.4\nREDHAT_SUPPORT_PRODUCT=\"Scientific Linux\"\nREDHAT_SUPPORT_PRODUCT_VERSION=\"7.4\"\n",
        }
        platform = scan_with_files("linux", files)
        _(platform[:name]).must_equal("scientific")
        _(platform[:family]).must_equal("redhat")
        _(platform[:release]).must_equal("7.4")
      end
      it "sets the correct family, name, and release on CloudLinux" do
        files = {
          "/etc/redhat-release" => "CloudLinux release 7.4 (Georgy Grechko)\n",
          "/etc/os-release" => "NAME=\"CloudLinux\"\nVERSION=\"7.4 (Georgy Grechko)\"\nID=\"cloudlinux\"\nID_LIKE=\"rhel fedora centos\"\nVERSION_ID=\"7.4\"\nPRETTY_NAME=\"CloudLinux 7.4 (Georgy Grechko)\"\nANSI_COLOR=\"0;31\"\nCPE_NAME=\"cpe:/o:cloudlinux:cloudlinux:7.4:GA:server\"\nHOME_URL=\"https://www.cloudlinux.com//\"\nBUG_REPORT_URL=\"https://www.cloudlinux.com/support\"\n",
        }
        platform = scan_with_files("linux", files)
        _(platform[:name]).must_equal("cloudlinux")
        _(platform[:family]).must_equal("redhat")
        _(platform[:release]).must_equal("7.4")
      end
      it "sets the correct family, name, and release on SLES ESR RHEL" do
        files = {
          "/etc/redhat-release" => "Red Hat Enterprise Linux Server release 7.4 (Maipo)\n# This is a \"SLES Expanded Support platform release 7.4\"\n# The above \"Red Hat Enterprise Linux Server\" string is only used to \n# keep software compatibility.\n",
          "/etc/os-release" => "NAME=\"Red Hat Enterprise Linux Server\"\nVERSION=\"7.4 (Maipo)\"\nID=\"rhel\"\nID_LIKE=\"fedora\"\nVERSION_ID=\"7.4\"\nPRETTY_NAME=\"Red Hat Enterprise Linux Server 7.4\"\nANSI_COLOR=\"0;31\"\nCPE_NAME=\"cpe:/o:redhat:enterprise_linux:7.4:GA:server\"\nHOME_URL=\"https://www.redhat.com/\"\nBUG_REPORT_URL=\"https://bugzilla.redhat.com/\"\n\nREDHAT_BUGZILLA_PRODUCT=\"Red Hat Enterprise Linux 7\"\nREDHAT_BUGZILLA_PRODUCT_VERSION=7.4\nREDHAT_SUPPORT_PRODUCT=\"Red Hat Enterprise Linux\"\nREDHAT_SUPPORT_PRODUCT_VERSION=7.4\n# This is a \"SLES Expanded Support platform release 7.4\"\n# The above \"Red Hat Enterprise Linux Server\" string is only used to\n# keep software compatibility.\n",
        }
        platform = scan_with_files("linux", files)
        _(platform[:name]).must_equal("redhat")
        _(platform[:family]).must_equal("redhat")
        _(platform[:release]).must_equal("7.4")
      end
    end
  end

  describe "darwin" do
    describe "mac_os_x" do
      it "sets the correct family, name, and release on os_x" do
        files = {
          "/System/Library/CoreServices/SystemVersion.plist" => "<string>Mac OS X</string>",
        }
        platform = scan_with_files("darwin", files)
        _(platform[:name]).must_equal("mac_os_x")
        _(platform[:family]).must_equal("darwin")
        _(platform[:release]).must_equal("test-release")
      end
    end

    describe "generic darwin" do
      it "sets the correct family, name, and release on darwin" do
        files = {
          "/usr/bin/sw_vers" => "ProductVersion: 17.0.1\nBuildVersion: alpha.x1",
        }
        platform = scan_with_files("darwin", files)
        _(platform[:name]).must_equal("darwin")
        _(platform[:family]).must_equal("darwin")
        _(platform[:release]).must_equal("17.0.1")
        _(platform[:build]).must_equal("alpha.x1")
      end
    end
  end

  describe "/etc/debian_version" do
    def debian_scan(id, version)
      lsb_release = "DISTRIB_ID=#{id}\nDISTRIB_RELEASE=#{version}"
      files = {
        "/etc/lsb-release" => lsb_release,
        "/etc/debian_version" => "11",
      }
      scan_with_files("linux", files)
    end

    describe "ubuntu" do
      it "sets the correct family/release for ubuntu" do
        platform = debian_scan("ubuntu", "16.04")

        _(platform[:name]).must_equal("ubuntu")
        _(platform[:family]).must_equal("debian")
        _(platform[:release]).must_equal("16.04")
      end
    end

    describe "linuxmint" do
      it "sets the correct family/release for linuxmint" do
        platform = debian_scan("linuxmint", "12")

        _(platform[:name]).must_equal("linuxmint")
        _(platform[:family]).must_equal("debian")
        _(platform[:release]).must_equal("12")
      end
    end

    describe "raspbian" do
      it "sets the correct family/release for raspbian " do
        files = {
          "/usr/bin/raspi-config" => "data",
          "/etc/debian_version" => "13.6",
        }
        platform = scan_with_files("linux", files)

        _(platform[:name]).must_equal("raspbian")
        _(platform[:family]).must_equal("debian")
        _(platform[:release]).must_equal("13.6")
      end
    end

    describe "windows" do
      it "sets the correct family/release for windows " do
        platform = scan_with_windows

        _(platform[:name]).must_equal("windows_6.3.9600")
        _(platform[:family]).must_equal("windows")
        _(platform[:release]).must_equal("6.3.9600")
      end
    end

    describe "everything else" do
      it "sets the correct family/release for debian " do
        platform = debian_scan("some_debian", "12.99")

        _(platform[:name]).must_equal("debian")
        _(platform[:family]).must_equal("debian")
        _(platform[:release]).must_equal("11")
      end
    end
  end

  describe "windows" do
    it "sets the correct family/release for windows " do
      platform = scan_with_windows

      _(platform[:name]).must_equal("windows_6.3.9600")
      _(platform[:family]).must_equal("windows")
      _(platform[:release]).must_equal("6.3.9600")
    end
  end

  describe "/etc/coreos/update.conf" do
    it "sets the correct family/release for coreos" do
      lsb_release = "DISTRIB_ID=Container Linux by CoreOS\nDISTRIB_RELEASE=27.9"
      files = {
        "/etc/lsb-release" => lsb_release,
        "/etc/coreos/update.conf" => "data",
      }
      platform = scan_with_files("linux", files)

      _(platform[:name]).must_equal("coreos")
      _(platform[:family]).must_equal("linux")
      _(platform[:release]).must_equal("27.9")
    end
  end

  describe "/etc/os-release" do
    describe "when not on a wrlinux build" do
      it "fail back to generic linux" do
        os_release = "ID_LIKE=cisco-unkwown\nVERSION=unknown"
        files = {
          "/etc/os-release" => os_release,
        }
        platform = scan_with_files("linux", files)

        _(platform[:name]).must_equal("linux")
        _(platform[:family]).must_equal("linux")
      end
    end

    describe "when on a wrlinux build" do
      it "sets the correct family/release for wrlinux" do
        os_release = "ID_LIKE=cisco-wrlinux\nVERSION=cisco123"
        files = {
          "/etc/os-release" => os_release,
        }
        platform = scan_with_files("linux", files)

        _(platform[:name]).must_equal("wrlinux")
        _(platform[:family]).must_equal("redhat")
        _(platform[:release]).must_equal("cisco123")
      end
    end

    describe "when on a suse build" do
      describe "when /etc/os-release is present" do
        it "sets the correct family/release for SLES" do
          files = {
            "/etc/os-release" => "NAME=\"SLES\"\nVERSION=\"15.1\"\nID=\"sles\"\nID_LIKE=\"suse\"\n",
          }
          platform = scan_with_files("linux", files)

          _(platform[:name]).must_equal("suse")
          _(platform[:family]).must_equal("suse")
          _(platform[:release]).must_equal("15.1")
        end

        it "sets the correct family/release for openSUSE" do
          files = {
            "/etc/os-release" => "NAME=\"openSUSE Leap\"\nVERSION=\"15.1\"\nID=\"opensuse-leap\"\nID_LIKE=\"suse opensuse\"\n",
          }
          platform = scan_with_files("linux", files)

          _(platform[:name]).must_equal("opensuse")
          _(platform[:family]).must_equal("suse")
          _(platform[:release]).must_equal("15.1")
        end
      end
      describe "when /etc/os-release is not present" do
        it "sets the correct family/release for SLES" do
          files = {
            "/etc/SuSE-release" => "SUSE Linux Enterprise Server 11 (x86_64)\nVERSION = 11\nPATCHLEVEL = 2",
          }
          platform = scan_with_files("linux", files)

          _(platform[:name]).must_equal("suse")
          _(platform[:family]).must_equal("suse")
          _(platform[:release]).must_equal("11.2")
        end

        it "sets the correct family/release for openSUSE" do
          files = {
            "/etc/SuSE-release" => "openSUSE 10.2 (x86_64)\nVERSION = 10.2",
          }
          platform = scan_with_files("linux", files)

          _(platform[:name]).must_equal("opensuse")
          _(platform[:family]).must_equal("suse")
          _(platform[:release]).must_equal("10.2")
        end
      end
    end
  end

  describe "yocto" do
    it "sets the correct family, name, and release on yocto" do
      files = {
        "/etc/issue" => "Poky (Yocto Project Reference Distro) 2.7 \\n \\l",
      }
      platform = scan_with_files("linux", files)
      _(platform[:name]).must_equal("yocto")
      _(platform[:family]).must_equal("yocto")
      _(platform[:release]).must_equal("2.7")
    end
  end

  describe "balenaos" do
    it "sets the correct family, name, and release on balenaos" do
      files = {
        "/etc/issue" => "balenaOS 2.46.1 \n \l",
        "/etc/os-release" => "ID=\"balena-os\"\nNAME=\"balenaOS\"\nVERSION=\"2.46.1+rev1\"\nVERSION_ID=\"2.46.1+rev1\"\nPRETTY_NAME=\"balenaOS 2.46.1+rev1\"\nMACHINE=\"raspberrypi3\"\nVARIANT=\"Development\"\nVARIANT_ID=\"dev\"\nMETA_BALENA_VERSION=\"2.46.1\"\nRESIN_BOARD_REV=\"e194600\"\nMETA_RESIN_REV=\"f2295d2\"\nSLUG=\"raspberrypi3\"\n",
      }
      platform = scan_with_files("linux", files)
      _(platform[:name]).must_equal("balenaos")
      _(platform[:family]).must_equal("yocto")
      _(platform[:release]).must_equal("2.46.1")
    end
  end

  describe "qnx" do
    it "sets the correct info for qnx platform" do
      platform = scan_with_files("qnx", {})

      _(platform[:name]).must_equal("qnx")
      _(platform[:family]).must_equal("qnx")
      _(platform[:release]).must_equal("test-release")
    end
  end

  describe "cisco" do
    it "recognizes Cisco IOS12" do
      mock = Train::Transports::Mock::Connection.new
      mock.mock_command("show version", "Cisco IOS Software, C3750E Software (C3750E-UNIVERSALK9-M), Version 12.2(58)SE")
      platform = Train::Platforms::Detect.scan(mock)

      _(platform[:name]).must_equal("cisco_ios")
      _(platform[:family]).must_equal("cisco")
      _(platform[:release]).must_equal("12.2")
    end

    it "recognizes Cisco IOS XE" do
      mock = Train::Transports::Mock::Connection.new
      mock.mock_command("show version", "Cisco IOS Software, IOS-XE Software, Catalyst L3 Switch Software (CAT3K_CAA-UNIVERSALK9-M), Version 03.03.03SE RELEASE SOFTWARE (fc2)")
      platform = Train::Platforms::Detect.scan(mock)

      _(platform[:name]).must_equal("cisco_ios_xe")
      _(platform[:family]).must_equal("cisco")
      _(platform[:release]).must_equal("03.03.03SE")
    end

    it "recognizes Cisco Nexus" do
      mock = Train::Transports::Mock::Connection.new
      mock.mock_command("show version", "Cisco Nexus Operating System (NX-OS) Software\n  system:      version 5.2(1)N1(8b)\n")
      platform = Train::Platforms::Detect.scan(mock)

      _(platform[:name]).must_equal("cisco_nexus")
      _(platform[:family]).must_equal("cisco")
      _(platform[:release]).must_equal("5.2")
    end
  end

  describe "brocade" do
    it "recognizes Brocade FOS-based SAN switches" do
      mock = Train::Transports::Mock::Connection.new
      mock.mock_command("version", "Kernel:     2.6.14.2\nFabric OS:  v7.4.2a\nMade on:    Thu Jun 29 19:22:14 2017\nFlash:      Sat Sep 9 17:30:42 2017\nBootProm:   1.0.11")
      platform = Train::Platforms::Detect.scan(mock)

      _(platform[:name]).must_equal("brocade_fos")
      _(platform[:family]).must_equal("brocade")
      _(platform[:release]).must_equal("7.4.2a")
    end
  end
end
