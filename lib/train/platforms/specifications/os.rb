plat = Train::Platforms

# windows platform
plat.name('windows')
    .detect {
      return true if @platform[:name] =~ /windows|microsoft/i
    }

# unix master family
plat.family('unix')
    .detect {
      if uname_s =~ /linux/i
        @platform[:family] = 'linux'
        @platform[:type] = 'unix'
        true
      elsif uname_s =~ /./
        @platform[:type] = 'unix'
        true
      end
    }

# linux master family
plat.family('linux').in_family('unix')
    .detect {
      if @platform[:family] == 'linux'
        detect_linux_arch # sets arch in @platform[:arch]
        true
      end
    }

# debian family
plat.family('debian').in_family('linux')
    .detect {
      true unless get_config('/etc/debian_version').nil?
    }
plat.name('debian').title('Debian Linux').in_family('debian')
    .detect {
      lsb = detect_linux_lsb
      if lsb && lsb[:id] =~ /debian/i
        @platform[:release] = lsb[:release]
        true
      end
    }
plat.name('ubuntu').title('Ubuntu Linux').in_family('debian')
    .detect {
      lsb = detect_linux_lsb
      if lsb && lsb[:id] =~ /ubuntu/i
        @platform[:release] = lsb[:release]
        true
      end
    }
plat.name('linuxmint').title('LinuxMint').in_family('debian')
    .detect {
      lsb = detect_linux_lsb
      if lsb && lsb[:id] =~ /linuxmint/i
        @platform[:release] = lsb[:release]
        true
      end
    }
plat.name('raspbian').title('Raspbian Linux').in_family('debian')
    .detect {
      if unix_file?('/usr/bin/raspi-config')
        @platform[:release] = get_config('/etc/debian_version').chomp
        true
      end
    }
plat.name('backtrack', release: '>= 4').in_family('debian')

# redhat family
plat.family('redhat').in_family('linux')
    .detect {
      # I am not sure this returns true for all redhats in this family
      # for now we are going to just try each platform
      # return true unless get_config('/etc/redhat-release').nil?

      true
    }
plat.name('redhat').title('Red Hat Enterplat.ise Linux').in_family('redhat')
    .detect {
      lsb = detect_linux_lsb
      if lsb && lsb[:id] =~ /redhat/i
        @platform[:release] = lsb[:release]
        true
      end
    }
plat.name('centos').title('Centos Linux').in_family('redhat')
    .detect {
      lsb = detect_linux_lsb
      if lsb && lsb[:id] =~ /centos/i
        @platform[:release] = lsb[:release]
        true
      elsif get_config('/etc/os-release') =~ /centos/i
        @platform[:release] = redhatish_version(raw)
        true
      end
    }
plat.name('oracle').title('Oracle Linux').in_family('redhat')
    .detect {
      if !(raw = get_config('/etc/oracle-release')).nil?
        @platform[:name] = 'oracle'
        @platform[:release] = redhatish_version(raw)
        true
      elsif !(raw = get_config('/etc/enterprise-release')).nil?
        @platform[:name] = 'oracle'
        @platform[:release] = redhatish_version(raw)
        true
      end
    }
plat.name('amazon').title('Amazon Linux').in_family('redhat')
    .detect {
      lsb = detect_linux_lsb
      if lsb && lsb[:id] =~ /amazon/i
        @platform[:name] = 'amazon'
        @platform[:release] = lsb[:release]
        true
      elsif !(raw = get_config('/etc/system-release')).nil?
        # Amazon Linux
        @platform[:name] = redhatish_platform(raw)
        @platform[:release] = redhatish_version(raw)
        true
      end
    }
plat.name('scientific').title('Scientific Linux').in_family('redhat')
    .detect {
      # for now this is detected at the start during the lsb call
    }
plat.name('xenserver').title('Xenserer Linux').in_family('redhat')
    .detect {
      # for now this is detected at the start during the lsb call
    }
plat.name('parallels-release').title('Parallels Linux').in_family('redhat')
    .detect {
      if !(raw = get_config('/etc/parallels-release')).nil?
        @platform[:name] = redhatish_platform(raw)
        @platform[:release] = raw[/(\d\.\d\.\d)/, 1]
        true
      end
    }
plat.name('wrlinux').title('Wind River Linux').in_family('redhat')
    .detect {
      if !(os_info = fetch_os_release).nil?
        if os_info['ID_LIKE'] =~ /wrlinux/
          @platform[:name] = 'wrlinux'
          @platform[:release] = os_info['VERSION']
          true
        end
      end
    }

# suse family
plat.family('suse').in_family('linux')
    .detect {
      if !(suse = get_config('/etc/SuSE-release')).nil?
        version = suse.scan(/VERSION = (\d+)\nPATCHLEVEL = (\d+)/).flatten.join('.')
        version = suse[/VERSION = ([\d\.]{2,})/, 1] if version == ''
        @platform[:release] = version
        true
      end
    }
plat.name('opensuse').title('OpenSUSE Linux').in_family('suse')
    .detect {
      return true if get_config('/etc/SuSE-release') =~ /^openSUSE/
      # release set at the family level
    }
plat.name('suse').title('Suse Linux').in_family('suse')
    .detect {
      return true if get_config('/etc/SuSE-release') =~ /suse/
      # release set at the family level
    }



# arch
plat.name('arch').title('Arch Linux').in_family('linux')
    .detect {
      if !get_config('/etc/arch-release').nil?
        # Because this is a rolling release distribution,
        # use the kernel release, ex. 4.1.6-1-ARCH
        @platform[:release] = uname_r
        true
      end
    }

# slackware
plat.name('slackware').title('Slackware Linux').in_family('linux')
    .detect {
      if !(raw = get_config('/etc/slackware-version')).nil?
        @platform[:release] = raw.scan(/(\d+|\.+)/).join
        true
      end
    }

# gentoo
plat.name('gentoo').title('Gentoo Linux').in_family('linux')
    .detect {
      if !(raw = get_config('/etc/gentoo-release')).nil?
        @platform[:release] = raw.scan(/(\d+|\.+)/).join
        true
      end
    }

# exherbo
plat.name('exherbo').title('Exherbo Linux').in_family('linux')
    .detect {
      if !(raw = get_config('/etc/exherbo-release')).nil?
        # Because this is a rolling release distribution,
        # use the kernel release, ex. 4.1.6
        @platform[:release] = uname_r
        true
      end
    }

# alpine
plat.name('alpine').title('Alpine Linux').in_family('linux')
    .detect {
      if !(raw = get_config('/etc/alpine-release')).nil?
        @platform[:release] = raw.strip
        true
      end
    }

# coreos
plat.name('coreos').title('CoreOS Linux').in_family('linux')
    .detect {
      if !get_config('/etc/coreos/update.conf').nil?
        @platform[:release] = lsb[:release]
        true
      end
    }

# genaric linux
plat.name('linux').title('Genaric Linux').in_family('linux')
    .detect {
      true
    }

# aix
plat.name('aix').title('Aix').in_family('unix')
    .detect {
      if uname_s =~ /aix/
        out = @backend.run_command('uname -rvp').stdout
        m = out.match(/(\d+)\s+(\d+)\s+(.*)/)
        unless m.nil?
          @platform[:release] = "#{m[2]}.#{m[1]}"
          @platform[:arch] = m[3].to_s
        end
        true
      end
    }

# solaris family
plat.family('solaris').in_family('unix')
    .detect {
      # we need a better way to determin this family
      true
    }

# solaris
plat.name('solaris').title('Solaris').in_family('solaris')
    .detect {
      # TODO: REDO
      true if @platform[:name] =~ /solaris/
    }

# hpux
plat.name('hpux').title('Hpux').in_family('unix')
    .detect {
      if uname_s =~ /hp-ux/
        @platform[:release] = uname_r.lines[0].chomp
        true
      end
    }

# bsd family
plat.family('bsd').in_family('unix')
    .detect {
      # we need a better way to determin this family
      true
    }
plat.name('darwin').title('Darwin').in_family('bsd')
    .detect {
      if uname_s =~ /darwin/
        @platform[:name] = uname_s.lines[0].chomp
        @platform[:release] = uname_r.lines[0].chomp
        true
      end
    }
plat.name('freebsd').title('Freebsd').in_family('bsd')
    .detect {
      if uname_s =~ /freebsd/
        @platform[:name] = uname_s.lines[0].chomp
        @platform[:release] = uname_r.lines[0].chomp
        true
      end
    }
plat.name('openbsd').title('Openbsd').in_family('bsd')
    .detect {
      if uname_s =~ /openbsd/
        @platform[:name] = uname_s.lines[0].chomp
        @platform[:release] = uname_r.lines[0].chomp
        true
      end
    }
plat.name('netbsd').title('Netbsd').in_family('bsd')
    .detect {
      if uname_s =~ /netbsd/
        @platform[:name] = uname_s.lines[0].chomp
        @platform[:release] = uname_r.lines[0].chomp
        true
      end
    }
