# encoding: utf-8

require 'train/platforms/detect/linux_lsb'
require 'train/platforms/detect/uname'

module Train::Platforms::Detect
  module Linux # rubocop:disable Metrics/ModuleLength
    include Train::Platforms::Detect::LinuxLSB
    include Train::Platforms::Detect::Uname

    def redhatish_platform(conf)
      conf[/^red hat/i] ? 'redhat' : conf[/(\w+)/i, 1].downcase
    end

    def redhatish_version(conf)
      return conf[/((\d+) \(Rawhide\))/i, 1].downcase if conf[/rawhide/i]
      return conf[/Linux ((\d+|\.)+)/i, 1] if conf[/derived from .*linux/i]
      conf[/release ([\d\.]+)/, 1]
    end

    def detect_linux_arch
      @platform[:arch] = uname_m
    end

    def detect_linux
      # TODO: print an error in this step of the detection
      return false if uname_s.nil? || uname_s.empty?
      return false if uname_r.nil? || uname_r.empty?

      detect_linux_arch
    end

    def fetch_os_release
      data = get_config('/etc/os-release')
      return if data.nil?

      os_info = parse_os_release_info(data)
      cisco_info_file = os_info['CISCO_RELEASE_INFO']
      if cisco_info_file
        os_info.merge!(parse_os_release_info(get_config(cisco_info_file)))
      end

      os_info
    end

    def parse_os_release_info(raw)
      return {} if raw.nil?

      raw.lines.each_with_object({}) do |line, memo|
        line.strip!
        key, value = line.split('=', 2)
        memo[key] = value.gsub(/\A"|"\Z/, '') unless value.empty?
      end
    end
  end
end
