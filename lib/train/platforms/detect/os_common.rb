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
      return @files[path] unless @files[path].nil?

      res = @backend.run_command("test -f #{path} && cat #{path}")
      @files[path] = res.stdout
      # ignore files that can't be read
      return nil if res.exit_status != 0
      res.stdout
    end

    def unix_file_exist?(path)
      @backend.run_command("test -f #{path}").exit_status.zero?
    end

    def unix_uname_s
      return @uname[:s] unless @uname[:s].nil?
      @uname[:s] = @backend.run_command('uname -s').stdout
    end

    def unix_uname_r
      return @uname[:r] unless @uname[:r].nil?
      @uname[:r] = begin
                     res = @backend.run_command('uname -r').stdout
                     res.strip! unless res.nil?
                     res
                   end
    end

    def unix_uname_m
      return @uname[:m] unless @uname[:m].nil?
      @uname[:m] = @backend.run_command('uname -m').stdout.chomp
    end
  end
end
