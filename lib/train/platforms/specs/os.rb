plat = Train::Platforms

# unix
plat.family('unix')
    .detect {
      if @platform.empty? || @platform[:family] == 'unix'
        detect_family
        true
      end
    }

# linux
plat.family('linux').is_a('unix')
    .detect {
      if @platform[:family] == 'linux'
        detect_linux
        detect_linux_via_lsb
        true
      end
    }

# debian
plat.family('debian').is_a('linux')
    .detect {
      if !(raw = get_config('/etc/debian_version')).nil?
        true
      end
    }
plat.name('ubuntu').title('Ubuntu Linux').is_a('debian')
    .detect {
      if @lsb[:id] =~ /ubuntu/i
        @platform[:name] = 'ubuntu'
        @platform[:release] = lsb[:release]
        true
      end
    }
plat.name('linuxmint').title('LinuxMint').is_a('debian')
    .detect {
      if @lsb[:id] =~ /ubuntu/i
        @platform[:name] = 'linuxmint'
        @platform[:release] = lsb[:release]
        true
      end
    }
plat.name('raspbian').title('Raspbian Linux').is_a('debian')
    .detect {
      if unix_file?('/usr/bin/raspi-config')
        @platform[:name] = 'raspbian'
        @platform[:release] = raw.chomp
        true
      end
    }
plat.name('backtrack', release: '>= 4').is_a('debian')
plat.name('debian').title('Debian Linux').is_a('debian')
    .detect {
      # Must be a debian
      unless @lsb.nil?
        @platform[:name] = 'debian'
        @platform[:release] = lsb[:release]
        true
      end
    }

# redhat
plat.family('redhat').is_a('linux')
    .detect {
      if !(raw = get_config('/etc/redhat-release')).nil?
        # TODO: Cisco
        # TODO: fully investigate os-release and integrate it;
        # here we just use it for centos
        @platform[:name] = if !(osrel = get_config('/etc/os-release')).nil? && osrel =~ /centos/i
                             'centos'
                           else
                             redhatish_platform(raw)
                           end

        @platform[:release] = redhatish_version(raw)
        true
      end

      # There is no easy way to detect the redhat family. This
      # will detect all redhats at the platform level
      true
    }
plat.name('centos').title('Centos Linux').is_a('redhat')
    .detect {
      true if @plaform[:name] == 'centos'
    }
plat.name('rhel').title('Red Hat Enterplat.ise Linux').is_a('redhat')
    .detect {
      true if @plaform[:name] == 'rhel'
    }
plat.name('oracle').title('Oracle Linux').is_a('redhat')
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
plat.name('amazon').title('Amazon Linux').is_a('redhat')
    .detect {
      if !(raw = get_config('/etc/system-release')).nil?
        # Amazon Linux
        @platform[:name] = redhatish_platform(raw)
        @platform[:release] = redhatish_version(raw)
        true
      end
    }
plat.name('parallels-release').title('Parallels Linux').is_a('redhat')
    .detect {
      if !(raw = get_config('/etc/parallels-release')).nil?
        @platform[:name] = redhatish_platform(raw)
        @platform[:release] = raw[/(\d\.\d\.\d)/, 1]
        true
      end
    }
plat.name('wrlinux').title('Wind River Linux').is_a('redhat')
    .detect {
      if !(os_info = fetch_os_release).nil?
        if os_info['ID_LIKE'] =~ /wrlinux/
          @platform[:name] = 'wrlinux'
          @platform[:release] = os_info['VERSION']
          true
        end
      end
    }

# suse
plat.family('suse').is_a('linux')
    .detect {
      if !(suse = get_config('/etc/SuSE-release')).nil?
        version = suse.scan(/VERSION = (\d+)\nPATCHLEVEL = (\d+)/).flatten.join('.')
        version = suse[/VERSION = ([\d\.]{2,})/, 1] if version == ''
        @platform[:release] = version
        @platform[:name] =  if suse =~ /^openSUSE/
                              'opensuse'
                            else
                              'suse'
                            end
        true
      end
    }
plat.name('suse').title('Suse Linux').is_a('suse')
    .detect {
      true if @plaform[:name] == 'suse'
    }
plat.name('opensuse').title('OpenSUSE Linux').is_a('suse')
    .detect {
      true if @plaform[:name] == 'opensuse'
    }

# arch
plat.family('arch').is_a('linux')
    .detect {
      if !get_config('/etc/arch-release').nil?
        @platform[:name] = 'arch'
        # Because this is a rolling release distribution,
        # use the kernel release, ex. 4.1.6-1-ARCH
        @platform[:release] = uname_r
        true
      end
    }
plat.name('arch').title('Arch Linux').is_a('arch')
    .detect {
      true if @plaform[:name] == 'arch'
    }

# slackware
plat.name('slackware').title('Slackware Linux').is_a('linux')
    .detect {
      if !(raw = get_config('/etc/slackware-version')).nil?
        @platform[:name] = 'slackware'
        @platform[:release] = raw.scan(/(\d+|\.+)/).join
        true
      end
    }

# gentoo
plat.name('gentoo').title('Gentoo Linux').is_a('linux')
    .detect {
      if !(raw = get_config('/etc/gentoo-release')).nil?
        @platform[:name] = 'gentoo'
        @platform[:release] = raw.scan(/(\d+|\.+)/).join
        true
      end
    }

# exherbo
plat.name('exherbo').title('Exherbo Linux').is_a('linux')
    .detect {
      if !(raw = get_config('/etc/exherbo-release')).nil?
        @platform[:name] = 'exherbo'
        # Because this is a rolling release distribution,
        # use the kernel release, ex. 4.1.6
        @platform[:release] = uname_r
        true
      end
    }

# alpine
plat.name('alpine').title('Alpine Linux').is_a('linux')
    .detect {
      if !(raw = get_config('/etc/alpine-release')).nil?
        @platform[:name] = 'alpine'
        @platform[:release] = raw.strip
        true
      end
    }

# coreos
plat.name('coreos').title('CoreOS Linux').is_a('linux')
    .detect {
      if !get_config('/etc/coreos/update.conf').nil?
        @platform[:name] = 'coreos'
        @platform[:release] = lsb[:release]
        true
      end
    }

# genaric linux
plat.name('linux').title('Genaric Linux').is_a('linux')
    .detect {
      true
    }
