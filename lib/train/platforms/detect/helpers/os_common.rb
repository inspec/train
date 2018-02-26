# encoding: utf-8

require 'train/platforms/detect/helpers/os_linux'
require 'train/platforms/detect/helpers/os_windows'
require 'rbconfig'

module Train::Platforms::Detect::Helpers
  module OSCommon
    include Train::Platforms::Detect::Helpers::Linux
    include Train::Platforms::Detect::Helpers::Windows

    def ruby_host_os(regex)
      ::RbConfig::CONFIG['host_os'] =~ regex
    end

    def winrm?
      Object.const_defined?('Train::Transports::WinRM::Connection') &&
        @backend.class == Train::Transports::WinRM::Connection
    end

    def unix_file_contents(path)
      # keep a log of files incase multiple checks call the same one
      return @files[path] if @files.key?(path)

      res = @backend.run_command("test -f #{path} && cat #{path}")
      # ignore files that can't be read
      @files[path] = res.exit_status.zero? ? res.stdout : nil
      @files[path]
    end

    def unix_file_exist?(path)
      @backend.run_command("test -f #{path}").exit_status.zero?
    end

    def command_output(cmd)
      res = @backend.run_command(cmd).stdout
      res.strip! unless res.nil?
      res
    end

    def unix_uname_s
      return @uname[:s] if @uname.key?(:s)
      @uname[:s] = command_output('uname -s')
    end

    def unix_uname_r
      return @uname[:r] if @uname.key?(:r)
      @uname[:r] = command_output('uname -r')
    end

    def unix_uname_m
      return @uname[:m] if @uname.key?(:m)
      @uname[:m] = command_output('uname -m')
    end

    def brocade_version
      return @cache[:brocade] if @cache.key?(:brocade)
      res = command_output('version')

      m = res.match(/^Fabric OS:\s+v(\S+)$/)
      unless m.nil?
        return @cache[:brocade] = { version: m[1], type: 'fos' }
      end

      @cache[:brocade] = nil
    end

    def cisco_show_version
      return @cache[:cisco] if @cache.key?(:cisco)
      res = command_output('show version')

      m = res.match(/^Cisco IOS Software, [^,]+? \(([^,]+?)\), Version (\d+\.\d+)/)
      unless m.nil?
        return @cache[:cisco] = { version: m[2], model: m[1], type: 'ios' }
      end

      m = res.match(/^Cisco IOS Software, IOS-XE Software, [^,]+? \(([^,]+?)\), Version (\d+\.\d+\.\d+[A-Z]*)/)
      unless m.nil?
        return @cache[:cisco] = { version: m[2], model: m[1], type: 'ios-xe' }
      end

      m = res.match(/^Cisco Nexus Operating System \(NX-OS\) Software/)
      unless m.nil?
        v = res[/^\s*system:\s+version (\d+\.\d+)/, 1]
        return @cache[:cisco] = { version: v, type: 'nexus' }
      end

      @cache[:cisco] = nil
    end
  end
end
