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

      m = res.match(/Cisco IOS Software, [^,]+? \(([^,]+?)\), Version (\d+\.\d+)/)
      unless m.nil?
        return @cache[:cisco] = { version: m[2], model: m[1], type: 'ios' }
      end

      m = res.match(/Cisco IOS Software, IOS-XE Software, [^,]+? \(([^,]+?)\), Version (\d+\.\d+\.\d+[A-Z]*)/)
      unless m.nil?
        return @cache[:cisco] = { version: m[2], model: m[1], type: 'ios-xe' }
      end

      m = res.match(/Cisco Nexus Operating System \(NX-OS\) Software/)
      unless m.nil?
        v = res[/^\s*system:\s+version (\d+\.\d+)/, 1]
        return @cache[:cisco] = { version: v, type: 'nexus' }
      end

      @cache[:cisco] = nil
    end

    def unix_uuid
      uuid = unix_uuid_from_chef
      uuid = unix_uuid_from_machine_file if uuid.nil?
      uuid = uuid_from_command if uuid.nil?
      raise Train::TransportError, 'Cannot find a UUID for your node.' if uuid.nil?
      uuid
    end

    def unix_uuid_from_chef
      file = @backend.file('/var/chef/cache/data_collector_metadata.json')
      if file.exist? && !file.size.zero?
        json = ::JSON.parse(file.content)
        return json['node_uuid'] if json['node_uuid']
      end
    end

    def unix_uuid_from_machine_file
      %W(
        /etc/chef/chef_guid
        #{ENV['HOME']}/.chef/chef_guid
        /etc/machine-id
        /var/lib/dbus/machine-id
        /var/db/dbus/machine-id
      ).each do |path|
        file = @backend.file(path)
        next unless file.exist? && !file.size.zero?
        return file.content.chomp if path =~ /guid/
        return uuid_from_string(file.content.chomp)
      end
      nil
    end

    # This takes a command from the platform detect block to run.
    # We expect the command to return a unique identifier which
    # we turn into a UUID.
    def uuid_from_command
      return unless @platform[:uuid_command]
      result = @backend.run_command(@platform[:uuid_command])
      uuid_from_string(result.stdout.chomp) if result.exit_status.zero? && !result.stdout.empty?
    end

    # This hashes the passed string into SHA1.
    # Then it downgrades the 160bit SHA1 to a 128bit
    # then we format it as a valid UUIDv5.
    def uuid_from_string(string)
      hash = Digest::SHA1.new
      hash.update(string)
      ary = hash.digest.unpack('NnnnnN')
      ary[2] = (ary[2] & 0x0FFF) | (5 << 12)
      ary[3] = (ary[3] & 0x3FFF) | 0x8000
      # rubocop:disable Style/FormatString
      '%08x-%04x-%04x-%04x-%04x%08x' % ary
    end
  end
end
