# encoding: utf-8

require 'rbconfig'

module Train::Platforms::Detect
  module OSLocal
    def detect_local_os
      case ::RbConfig::CONFIG['host_os']
      when /aix(.+)$/
        @platform[:name] = 'aix'
      when /darwin(.+)$/
        @platform[:name] = 'darwin'
      when /hpux(.+)$/
        @platform[:name] = 'hpux'
      when /linux/
        @platform[:name] = 'linux'
      when /freebsd(.+)$/
        @platform[:name] = 'freebsd'
      when /openbsd(.+)$/
        @platform[:name] = 'openbsd'
      when /netbsd(.*)$/
        @platform[:name] = 'netbsd'
      when /solaris2/
        @platform[:name] = 'solaris2'
      when /mswin|mingw32|windows/
        # After long discussion in IRC the "powers that be" have come to a consensus
        # that no Windows platform exists that was not based on the
        # Windows_NT kernel, so we herby decree that "windows" will refer to all
        # platforms built upon the Windows_NT kernel and have access to win32 or win64
        # subsystems.
        @platform[:name] = 'windows'
      else
        @platform[:name] = ::RbConfig::CONFIG['host_os']
      end
      Train::Platforms.list[@platform[:name]] if @platform[:name]
    end
  end
end
