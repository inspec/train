plat = Train::Platforms

# unix
plat.family('unix')
    .detect {
      true
    }

# linux
plat.family('linux').is_a('unix')
    .detect {
      detect_family
      true if @platform[:family] == 'linux'
    }

# debian
plat.family('debian').is_a('linux')
    .detect {
      if !(raw = get_config('/etc/debian_version')).nil?
        # load lsb info
        lsb
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

# genaric linux
plat.name('linux').title('Genaric Linux').is_a('linux')
    .detect {
      true
    }
