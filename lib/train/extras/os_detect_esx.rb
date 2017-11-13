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
  module DetectEsx
    def detect_esx
      if uname_s.downcase.chomp == 'vmkernel'
        @platform[:family] = 'esx'
        @platform[:name] = uname_s.lines[0].chomp
        @platform[:release] = uname_r.lines[0].chomp
        true
      end
    end
  end
end
