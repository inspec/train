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
  module DetectUnix
    def detect_via_uname # rubocop:disable Metrics/AbcSize
      case uname_s.downcase
      when /aix/
        @platform[:family] = 'aix'
        out = @backend.run_command('uname -rvp').stdout
        m = out.match(/(\d+)\s+(\d+)\s+(.*)/)
        unless m.nil?
          @platform[:release] = "#{m[2]}.#{m[1]}"
          @platform[:arch] = m[3].to_s
        end
      when /hp-ux/
        @platform[:family] = 'hpux'
        @platform[:name] = uname_s.lines[0].chomp
        @platform[:release] = uname_r.lines[0].chomp

      when /freebsd/
        @platform[:family] = 'freebsd'
        @platform[:name] = uname_s.lines[0].chomp
        @platform[:release] = uname_r.lines[0].chomp

      when /netbsd/
        @platform[:family] = 'netbsd'
        @platform[:name] = uname_s.lines[0].chomp
        @platform[:release] = uname_r.lines[0].chomp

      when /openbsd/
        @platform[:family] = 'openbsd'
        @platform[:name] = uname_s.lines[0].chomp
        @platform[:release] = uname_r.lines[0].chomp

      when /sunos/
        detect_solaris
      else
        # in all other cases we didn't detect it
        return false
      end
      # when we get here the detection returned a result
      true
    end

    def detect_solaris # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity
      # read specific os name
      # DEPRECATED: os[:family] is going to be deprecated, use os.solaris?
      rel = get_config('/etc/release')
      if /^.*(SmartOS).*$/ =~ rel
        @platform[:name] = 'smartos'
        @platform[:family] = 'smartos'
      elsif !(m = /^\s*(OmniOS).*r(\d+).*$/.match(rel)).nil?
        @platform[:name] = 'omnios'
        @platform[:family] = 'omnios'
        @platform[:release] = m[2]
      elsif !(m = /^\s*(OpenIndiana).*oi_(\d+).*$/.match(rel)).nil?
        @platform[:name] = 'openindiana'
        @platform[:family] = 'openindiana'
        @platform[:release] = m[2]
      elsif /^\s*(OpenSolaris).*snv_(\d+).*$/ =~ rel
        @platform[:name] = 'opensolaris'
        @platform[:family] = 'opensolaris'
        @platform[:release] = m[2]
      elsif !(m = /Oracle Solaris (\d+)/.match(rel)).nil?
        # TODO: should be string!
        @platform[:release] = m[1]
        @platform[:name] = 'solaris'
        @platform[:family] = 'solaris'
      elsif /^\s*(Solaris)\s.*$/ =~ rel
        @platform[:name] = 'solaris'
        @platform[:family] = 'solaris'
      elsif /^\s*(NexentaCore)\s.*$/ =~ rel
        @platform[:name] = 'nexentacore'
        @platform[:family] = 'nexentacore'
      else
        # unknown solaris
        @platform[:name] = 'solaris_distro'
        @platform[:family] = 'solaris'
      end

      # read release version
      unless (version = /^5\.(?<release>\d+)$/.match(uname_r)).nil?
        @platform[:release] = version['release']
      end

      # read architecture
      arch = @backend.run_command('uname -p')
      @platform[:arch] = arch.stdout.chomp if arch.exit_status == 0
    end
  end
end
