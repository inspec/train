# encoding: utf-8
# author: Dominik Richter
# author: Christoph Hartmann
#
# This is heavily based on:
#
#   OHAI https://github.com/chef/ohai
#   by Adam Jacob, Chef Software Inc
#
require 'json'

module Train::Extras
  module DetectEos
    def detect_eos
      output = @backend.run_command('show version | json').stdout
      if output
        eos_ver = JSON.parse(output)
        @platform[:family] = 'eos'
        @platform[:name] = 'eos'
        @platform[:release] = eos_ver['version']
        true
      end
    end
  end
end
