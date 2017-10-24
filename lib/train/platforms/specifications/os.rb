plat = Train::Platforms

plat.family('windows')
    .detect {
      require 'rbconfig'
      if winrm? || ::RbConfig::CONFIG['host_os'] =~ /mswin|mingw32|windows/
        @platform[:type] = 'windows'
        true
      end
    }
# windows platform
plat.name('windows').in_family('windows')
    .detect {
      true if detect_windows == true
    }

# unix master family
plat.family('unix')
    .detect {
      true if uname_s =~ /./
    }

# linux master family
plat.family('linux').in_family('unix')
    .detect {
      true if uname_s =~ /linux/i
    }

# debian family
plat.family('debian').in_family('linux')
    .detect {
      true unless read_file('/etc/debian_version').nil?
    }
plat.name('debian').title('Debian Linux').in_family('debian')
    .detect {
      lsb = read_linux_lsb
      if lsb && lsb[:id] =~ /debian/i
        @platform[:release] = lsb[:release]
        true
      end
    }
plat.name('ubuntu').title('Ubuntu Linux').in_family('debian')
    .detect {
      lsb = read_linux_lsb
      if lsb && lsb[:id] =~ /ubuntu/i
        @platform[:release] = lsb[:release]
        true
      end
    }
plat.name('linuxmint').title('LinuxMint').in_family('debian')
    .detect {
      lsb = read_linux_lsb
      if lsb && lsb[:id] =~ /linuxmint/i
        @platform[:release] = lsb[:release]
        true
      end
    }
plat.name('raspbian').title('Raspbian Linux').in_family('debian')
    .detect {
      if file_exist?('/usr/bin/raspi-config')
        @platform[:release] = read_file('/etc/debian_version').chomp
        true
      end
    }

# redhat family
plat.family('redhat').in_family('linux')
    .detect {
      # I am not sure this returns true for all redhats in this family
      # for now we are going to just try each platform
      # return true unless read_file('/etc/redhat-release').nil?

      true
    }
plat.name('centos').title('Centos Linux').in_family('redhat')
    .detect {
      lsb = read_linux_lsb
      if lsb && lsb[:id] =~ /centos/i
        @platform[:release] = lsb[:release]
        true
      elsif read_file('/etc/os-release') =~ /centos/i
        @platform[:release] = redhatish_version(read_file('/etc/redhat-release'))
        true
      end
    }
# keep redhat after centos as a catchall for redhat base
plat.name('redhat').title('Red Hat Enterplat.ise Linux').in_family('redhat')
    .detect {
      lsb = read_linux_lsb
      if lsb && lsb[:id] =~ /redhat/i
        @platform[:release] = lsb[:release]
        true
      elsif !(raw = read_file('/etc/redhat-release')).nil?
        # must be some type of redhat
        @platform[:name] = redhatish_platform(raw)
        @platform[:release] = redhatish_version(raw)
        true
      end
    }
plat.name('oracle').title('Oracle Linux').in_family('redhat')
    .detect {
      if !(raw = read_file('/etc/oracle-release')).nil?
        @platform[:release] = redhatish_version(raw)
        true
      elsif !(raw = read_file('/etc/enterprise-release')).nil?
        @platform[:release] = redhatish_version(raw)
        true
      end
    }
plat.name('scientific').title('Scientific Linux').in_family('redhat')
    .detect {
      lsb = read_linux_lsb
      if lsb && lsb[:id] =~ /scientificsl/i
        @platform[:release] = lsb[:release]
        true
      end
    }
plat.name('xenserver').title('Xenserer Linux').in_family('redhat')
    .detect {
      lsb = read_linux_lsb
      if lsb && lsb[:id] =~ /xenserver/i
        @platform[:release] = lsb[:release]
        true
      end
    }
plat.name('parallels-release').title('Parallels Linux').in_family('redhat')
    .detect {
      if !(raw = read_file('/etc/parallels-release')).nil?
        @platform[:name] = redhatish_platform(raw)
        @platform[:release] = raw[/(\d\.\d\.\d)/, 1]
        true
      end
    }
plat.name('wrlinux').title('Wind River Linux').in_family('redhat')
    .detect {
      if !(os_info = read_file('/etc/os-release')).nil?
        if os_info =~ /wrlinux/
          @platform[:name] = 'wrlinux'
          @platform[:release] = os_info[/VERSION\s?=\s?([\d\.]*)/, 1]
          true
        end
      end
    }
plat.name('amazon').title('Amazon Linux').in_family('redhat')
    .detect {
      lsb = read_linux_lsb
      if lsb && lsb[:id] =~ /amazon/i
        @platform[:release] = lsb[:release]
        true
      elsif !(raw = read_file('/etc/system-release')).nil?
        @platform[:name] = redhatish_platform(raw)
        @platform[:release] = redhatish_version(raw)
        true
      end
    }

# suse family
plat.family('suse').in_family('linux')
    .detect {
      if !(suse = read_file('/etc/SuSE-release')).nil?
        puts suse.inspect
        version = suse.scan(/VERSION = (\d+)\nPATCHLEVEL = (\d+)/).flatten.join('.')
        version = suse[/VERSION = ([\d\.]{2,})/, 1] if version == ''
        @platform[:release] = version
        true
      end
    }
plat.name('opensuse').title('OpenSUSE Linux').in_family('suse')
    .detect {
      true if read_file('/etc/SuSE-release') =~ /^openSUSE/
    }
plat.name('suse').title('Suse Linux').in_family('suse')
    .detect {
      true if read_file('/etc/SuSE-release') =~ /suse/
    }

# arch
plat.name('arch').title('Arch Linux').in_family('linux')
    .detect {
      if !read_file('/etc/arch-release').nil?
        # Because this is a rolling release distribution,
        # use the kernel release, ex. 4.1.6-1-ARCH
        @platform[:release] = uname_r
        true
      end
    }

# slackware
plat.name('slackware').title('Slackware Linux').in_family('linux')
    .detect {
      if !(raw = read_file('/etc/slackware-version')).nil?
        @platform[:release] = raw.scan(/(\d+|\.+)/).join
        true
      end
    }

# gentoo
plat.name('gentoo').title('Gentoo Linux').in_family('linux')
    .detect {
      if !(raw = read_file('/etc/gentoo-release')).nil?
        @platform[:release] = raw.scan(/(\d+|\.+)/).join
        true
      end
    }

# exherbo
plat.name('exherbo').title('Exherbo Linux').in_family('linux')
    .detect {
      if !(raw = read_file('/etc/exherbo-release')).nil?
        # Because this is a rolling release distribution,
        # use the kernel release, ex. 4.1.6
        @platform[:release] = uname_r
        true
      end
    }

# alpine
plat.name('alpine').title('Alpine Linux').in_family('linux')
    .detect {
      if !(raw = read_file('/etc/alpine-release')).nil?
        @platform[:release] = raw.strip
        true
      end
    }

# coreos
plat.name('coreos').title('CoreOS Linux').in_family('linux')
    .detect {
      if !read_file('/etc/coreos/update.conf').nil?
        @platform[:release] = lsb[:release]
        true
      end
    }

# genaric linux
# this should always be last in the linux family list
plat.name('linux').title('Genaric Linux').in_family('linux')
    .detect {
      true
    }

# openvms
plat.name('openvms').title('OpenVMS').in_family('unix')
    .detect {
      if uname_s =~ /unrecognized command verb/i
        cmd = @backend.run_command('show system/noprocess')
        unless cmd.exit_status != 0 || cmd.stdout.empty?
          @platform[:name] = cmd.stdout.downcase.split(' ')[0]
          cmd = @backend.run_command('write sys$output f$getsyi("VERSION")')
          @platform[:release] = cmd.stdout.downcase.split("\n")[1][1..-1]
          cmd = @backend.run_command('write sys$output f$getsyi("ARCH_NAME")')
          @platform[:arch] = cmd.stdout.downcase.split("\n")[1]
          true
        end
      end
    }

# arista_eos family
plat.family('arista_eos').in_family('unix')
    .detect {
      # we need a better way to determin this family
      true
    }
plat.name('arista_eos').title('Arista EOS').in_family('arista_eos')
    .detect {
      cmd = @backend.run_command('show version | json')
      if cmd.exit_status == 0 && !cmd.stdout.empty?
        require 'json'
        eos_ver = JSON.parse(cmd.stdout)
        @platform[:release] = eos_ver['version']
        @platform[:arch] = eos_ver['architecture']
        true
      end
    }
plat.name('arista_eos_bash').title('Arista EOS Bash Shell').in_family('arista_eos')
    .detect {
      if file_exist?('/usr/bin/FastCli')
        cmd = @backend.run_command('FastCli -p 15 -c "show version | json"')
        if cmd.exit_status == 0 && !cmd.stdout.empty?
          require 'json'
          eos_ver = JSON.parse(cmd.stdout)
          @platform[:release] = eos_ver['version']
          @platform[:arch] = eos_ver['architecture']
          true
        end
      end
    }

# esx
plat.name('esx').title('ESX').in_family('unix')
    .detect {
      if uname_s =~ /vmkernel/i
        @platform[:name] = uname_s.lines[0].chomp
        @platform[:release] = uname_r.lines[0].chomp
        true
      end
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
      if uname_s =~ /sunos/i
        unless (version = /^5\.(?<release>\d+)$/.match(uname_r)).nil?
          @platform[:release] = version['release']
        end

        arch = @backend.run_command('uname -p')
        @platform[:arch] = arch.stdout.chomp if arch.exit_status == 0
        true
      end
    }
plat.name('smartos').title('SmartOS').in_family('solaris')
    .detect {
      rel = read_file('/etc/release')
      if /^.*(SmartOS).*$/ =~ rel
        true
      end
    }
plat.name('omnios').title('Omnios').in_family('solaris')
    .detect {
      rel = read_file('/etc/release')
      if !(m = /^\s*(OmniOS).*r(\d+).*$/.match(rel)).nil?
        @platform[:release] = m[2]
        true
      end
    }
plat.name('openindiana').title('Openindiana').in_family('solaris')
    .detect {
      rel = read_file('/etc/release')
      if !(m = /^\s*(OpenIndiana).*oi_(\d+).*$/.match(rel)).nil?
        @platform[:release] = m[2]
        true
      end
    }
plat.name('opensolaris').title('Open Solaris').in_family('solaris')
    .detect {
      rel = read_file('/etc/release')
      if /^\s*(OpenSolaris).*snv_(\d+).*$/ =~ rel
        @platform[:release] = m[2]
        true
      end
    }
plat.name('nexentacore').title('Nexentacore').in_family('solaris')
    .detect {
      rel = read_file('/etc/release')
      if /^\s*(NexentaCore)\s.*$/ =~ rel
        true
      end
    }
plat.name('solaris').title('Solaris').in_family('solaris')
    .detect {
      rel = read_file('/etc/release')
      if !(m = /Oracle Solaris (\d+)/.match(rel)).nil?
        # TODO: should be string!
        @platform[:release] = m[1]
        true
      elsif /^\s*(Solaris)\s.*$/ =~ rel
        true
      else
        # must be some unknown solaris
        true
      end
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
      true
    }
plat.name('darwin').title('Darwin').in_family('bsd')
    .detect {
      if uname_s =~ /darwin/
        @platform[:name] = uname_s.lines[0].chomp
        @platform[:release] = uname_r.lines[0].chomp
        true
      end
      cmd = @backend.run_command('/usr/bin/sw_vers')
      return nil if cmd.exit_status != 0 || cmd.stdout.empty?

      @platform[:release] = cmd.stdout[/^ProductVersion:\s+(.+)$/, 1]
      @platform[:build] = cmd.stdout[/^BuildVersion:\s+(.+)$/, 1]
      @platform[:arch] = uname_m
      true
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
