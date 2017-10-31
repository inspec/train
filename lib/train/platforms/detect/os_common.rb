# encoding: utf-8

require 'train/platforms/detect/os_linux'
require 'train/platforms/detect/os_windows'
require 'rbconfig'

module Train::Platforms::Detect
  module OSCommon
    include Train::Platforms::Detect::Linux
    include Train::Platforms::Detect::Windows

    def rbconfig(regex)
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

    def uname_call(cmd)
      res = @backend.run_command(cmd).stdout
      res.strip! unless res.nil?
      res
    end

    def unix_uname_s
      return @uname[:s] if @uname.key?(:s)
      @uname[:s] = uname_call('uname -s')
    end

    def unix_uname_r
      return @uname[:r] if @uname.key?(:r)
      @uname[:r] = uname_call('uname -r')
    end

    def unix_uname_m
      return @uname[:m] if @uname.key?(:m)
      @uname[:m] = uname_call('uname -m')
    end
  end
end
