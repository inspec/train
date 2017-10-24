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
  end
end
