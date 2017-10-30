# encoding: utf-8

module Train::Platforms::Detect
  module Linux
    def redhatish_platform(conf)
      conf[/^red hat/i] ? 'redhat' : conf[/(\w+)/i, 1].downcase
    end

    def redhatish_version(conf)
      return conf[/((\d+) \(Rawhide\))/i, 1].downcase if conf[/rawhide/i]
      return conf[/Linux ((\d+|\.)+)/i, 1] if conf[/derived from .*linux/i]
      conf[/release ([\d\.]+)/, 1]
    end

    def linux_os_release
      data = unix_file_contents('/etc/os-release')
      return if data.nil?

      os_info = parse_os_release_info(data)
      cisco_info_file = os_info['CISCO_RELEASE_INFO']
      if cisco_info_file
        os_info.merge!(parse_os_release_info(unix_file_contents(cisco_info_file)))
      end

      os_info
    end

    def parse_os_release_info(raw)
      return {} if raw.nil?

      raw.lines.each_with_object({}) do |line, memo|
        line.strip!
        next if line.empty?
        key, value = line.split('=', 2)
        memo[key] = value.gsub(/\A"|"\Z/, '') unless value.empty?
      end
    end

    def lsb_config(content)
      {
        id:       content[/^DISTRIB_ID=["']?(.+?)["']?$/, 1],
        release:  content[/^DISTRIB_RELEASE=["']?(.+?)["']?$/, 1],
        codename: content[/^DISTRIB_CODENAME=["']?(.+?)["']?$/, 1],
      }
    end

    def lsb_release(content)
      {
        id:       content[/^Distributor ID:\s+(.+)$/, 1],
        release:  content[/^Release:\s+(.+)$/, 1],
        codename: content[/^Codename:\s+(.+)$/, 1],
      }
    end

    def read_linux_lsb
      return @lsb unless @lsb.empty?
      if !(raw = unix_file_contents('/etc/lsb-release')).nil?
        @lsb = lsb_config(raw)
      elsif !(raw = unix_file_contents('/usr/bin/lsb-release')).nil?
        @lsb = lsb_release(raw)
      end
    end
  end
end
