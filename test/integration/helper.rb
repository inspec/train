require "minitest/autorun"
require "minitest/spec"

# Tests configuration:
module Test
  class << self
    # MTime tracks the maximum range of modification time in seconds.
    # i.e. MTime == 60*60*1 is 1 hour of modification time range,
    # which translates to a modification time range of:
    #   [ now-1hour, now ]
    def mtime
      60 * 60 * 24 * 1
    end

    def dup(o)
      Marshal.load(Marshal.dump(o))
    end

    def root_group(os)
      case os[:family]
      when "freebsd"
        "wheel"
      when "aix"
        "system"
      else
        "root"
      end
    end

    def selinux_label(backend, path = nil)
      return nil if backend.class.to_s =~ /docker/i

      os = backend.os
      labels = {}

      h = {}
      h.default = Hash.new(nil)
      h["redhat"] = {}
      h["redhat"].default = "unconfined_u:object_r:user_tmp_t:s0"
      h["redhat"]["5.11"] = "user_u:object_r:tmp_t"
      h["centos"] = h["fedora"] = h["redhat"]
      labels.default = dup(h)

      h["redhat"].default = "unconfined_u:object_r:tmp_t:s0"
      labels["/tmp/block_device"] = dup(h)

      h = {}
      h.default = Hash.new(nil)
      h["redhat"] = {}
      h["redhat"].default = "system_u:object_r:null_device_t:s0"
      h["redhat"]["5.11"] = "system_u:object_r:null_device_t"
      h["centos"] = h["fedora"] = h["redhat"]
      labels["/dev/null"] = dup(h)

      labels[path][os[:family]][os[:release]]
    end
  end
end
