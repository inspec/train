# encoding: utf-8

require 'train/platforms/detect/os_linux'
require 'train/platforms/detect/linux_lsb'

module Train::Platforms::Detect
  module OSCommon
    include Train::Platforms::Detect::Linux
    include Train::Platforms::Detect::LinuxLSB

    def detect_family
      # if some information is already defined, try to verify it
      # with the remaining detection
      unless @platform[:family].nil?
        # return ok if the preconfigured family yielded a good result
        return true if detect_family_type
        # if not, reset the platform to presets and run the full detection
        # TODO: print an error message in this case, as the instantiating
        # backend is doing something wrong
        @platform = {}
      end

      # TODO: extend base implementation for detecting the family type
      # to Windows and others
      case uname_s
      when /unrecognized command verb/
        @platform[:family] = 'openvms'
      when /linux/i
        @platform[:family] = 'linux'
      when /./
        @platform[:family] = 'unix'
      else
        # Don't know what this is
        @platform[:family] = nil
      end

      # try to detect the platform if the platform is set to nil, otherwise this code will never work
      return nil if @platform[:family].nil?
      detect_family_type
    end

    def detect_family_type # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      pf = @platform[:family]

      return detect_windows if pf == 'windows'
      return detect_darwin if pf == 'darwin'
      return detect_esx if pf == 'esx'
      return detect_openvms if pf =='openvms'

      if %w{freebsd netbsd openbsd aix solaris2 hpux}.include?(pf)
        return detect_via_uname
      end

      # unix based systems combine the above
      return true if pf == 'unix' and detect_darwin
      return true if pf == 'unix' and detect_esx
      # This is assuming that pf is set to unix, this should be if pf == 'linux'
      return true if pf == 'unix' and detect_arista_eos
      return true if pf == 'unix' and detect_via_uname

      # if we arrive here, we most likey have a regular linux
      detect_linux
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
