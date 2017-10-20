# encoding: utf-8

require 'train/platforms/detect/os_linux'
require 'train/platforms/detect/os_windows'
require 'train/platforms/detect/linux_lsb'

module Train::Platforms::Detect
  module OSCommon
    include Train::Platforms::Detect::Linux
    include Train::Platforms::Detect::LinuxLSB
    include Train::Platforms::Detect::Windows

    def winrm?
      Object.const_defined?('Train::Transports::WinRM::Connection') &&
        @backend.class == Train::Transports::WinRM::Connection
    end

    def get_config(path)
      # keep a log of files incase multiple checks call the same one
      @config_files = {} if @config_files.nil?
      return @config_files[path] unless @config_files[path].nil?

      res = @backend.run_command("test -f #{path} && cat #{path}")
      # ignore files that can't be read
      return nil if res.exit_status != 0
      @config_files[path] = res.stdout
      res.stdout
    end

    def unix_file?(path)
      @backend.run_command("test -f #{path}").exit_status == 0
    end
  end
end
