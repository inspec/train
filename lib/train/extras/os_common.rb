# encoding: utf-8
# author: Dominik Richter
# author: Christoph Hartmann
#
# This is heavily based on:
#
#   OHAI https://github.com/chef/ohai
#   by Adam Jacob, Chef Software Inc
#

require 'train/extras/os_detect_darwin'
require 'train/extras/os_detect_linux'
require 'train/extras/os_detect_unix'
require 'train/extras/os_detect_windows'
require 'train/extras/os_detect_esx'
require 'train/extras/os_detect_arista_eos'
require 'train/extras/os_detect_openvms'

module Train::Extras
  class OSCommon
    include Train::Extras::DetectDarwin
    include Train::Extras::DetectLinux
    include Train::Extras::DetectUnix
    include Train::Extras::DetectWindows
    include Train::Extras::DetectEsx
    include Train::Extras::DetectAristaEos
    include Train::Extras::DetectOpenVMS

    attr_accessor :backend

    # @backend connection
    # @platfrom options inticate a platform familiy
    def initialize(backend, platform = nil)
      @backend = backend
      @platform = platform || {}
      detect_os
    end

    def [](key)
      @platform[key]
    end

    def to_hash
      @platform
    end

    # define helper methods on top of os family
    OS = { # rubocop:disable Style/MutableConstant
      'redhat' => REDHAT_FAMILY,
      'debian' => DEBIAN_FAMILY,
      'suse' => SUSE_FAMILY,
      'fedora' => %w{fedora},
      'bsd' => %w{
        freebsd netbsd openbsd darwin
      },
      'solaris' => %w{
        solaris smartos omnios openindiana opensolaris nexentacore
      },
      'windows' => %w{
        windows
      },
      'aix' => %w{
        aix
      },
      'hpux' => %w{
        hpux
      },
      'esx' => %w{
        esx
      },
      'darwin' => %w{
        darwin
      },
    }

    OS['linux'] = %w{linux alpine arch coreos exherbo gentoo slackware fedora amazon} + OS['redhat'] + OS['debian'] + OS['suse']

    OS['unix'] = %w{unix aix hpux qnx} + OS['linux'] + OS['solaris'] + OS['bsd']

    # Helper methods to check the OS type
    # Provides methods in the form of: linux?, unix?, solaris? ...
    OS.keys.each do |os_family|
      define_method((os_family + '?').to_sym) do
        OS[os_family].include?(@platform[:family])
      end
    end

    private

    # TODO: extend base implementation for detecting the family type
    # to Windows and others
    def detect_family
      # may be initialized by connection
      return @platform[:family] unless @platform[:family].nil?
      case uname_s
      when /unrecognized command verb/
        # uname is not available
        family = nil
      when /linux/i
        family = 'linux'
      when /./
        family = 'unix'
      else
        # Don't know what this is
        family = nil
      end
      family
    end

    def detect_os # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      pf = detect_family

      # shortcut for systems with uname_s
      return detect_windows if pf == 'windows'
      return if detect_linux

      return if (pf == 'unix' || pf == 'darwin') and detect_darwin
      return if (pf == 'unix' || pf == 'esx') and detect_esx

      # detect system based on uname
      if %w{unix freebsd netbsd openbsd aix solaris2 hpux}.include?(pf)
        return if detect_via_uname
      end

      return if pf == 'linux' and detect_arista_eos
      return if detect_openvms

      # if we arrive here, we most likey have a regular linux
      @platform[:family] = 'unknown'
    end

    def get_config(path)
      res = @backend.run_command("test -f #{path} && cat #{path}")
      # ignore files that can't be read
      return nil if res.exit_status != 0
      res.stdout
    end

    def unix_file?(path)
      @backend.run_command("test -f #{path}").exit_status == 0
    end
  end
end
