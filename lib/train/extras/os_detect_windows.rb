# encoding: utf-8
# author: Dominik Richter
# author: Christoph Hartmann
#
# This is heavily based on:
#
#   OHAI https://github.com/chef/ohai
#   by Adam Jacob, Chef Software Inc
#
module Train::Extras
  module DetectWindows
    def detect_windows
      res = @backend.run_command('cmd /c ver')
      return false if res.exit_status != 0 or res.stdout.empty?

      # if the ver contains `Windows`, we know its a Windows system
      version = res.stdout.strip
      return false unless version.downcase =~ /windows/
      @platform[:family] = 'windows'

      # try to extract release from eg. `Microsoft Windows [Version 6.3.9600]`
      release = /\[(?<name>.*)\]/.match(version)
      unless release[:name].nil?
        # release is 6.3.9600 now
        @platform[:release] = release[:name].downcase.gsub('version', '').strip
        # fallback, if we are not able to extract the name from wmic later
        @platform[:name] = "Windows #{@platform[:release]}"
      end

      # try to use wmic, but lets keep it optional
      read_wmic

      true
    end

    # reads os name and version from wmic
    # @see https://msdn.microsoft.com/en-us/library/bb742610.aspx#EEAA
    # Thanks to Matt Wrock (https://github.com/mwrock) for this hint
    def read_wmic
      res = @backend.run_command('wmic os get * /format:list')
      if res.exit_status == 0
        sys_info = {}
        res.stdout.lines.each { |line|
          m = /^\s*([^=]*?)\s*=\s*(.*?)\s*$/.match(line)
          sys_info[m[1].to_sym] = m[2] unless m.nil? || m[1].nil?
        }

        @platform[:release] = sys_info[:Version]
        # additional info on windows
        @platform[:build] = sys_info[:BuildNumber]
        @platform[:name] = sys_info[:Caption]
        @platform[:name] = @platform[:name].gsub('Microsoft', '').strip unless @platform[:name].empty?
        @platform[:arch] = sys_info[:OSArchitecture]
      end
    end
  end
end
