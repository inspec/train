# encoding: utf-8
# author: Jere Julian
#
# Arista EOS has 2 modes. Most compliance tests will use the network CLI
# but when working with vagrant, its common to encounter the raw bash shell.
require 'json'

module Train::Extras
  module DetectAristaEos
    def detect_arista_eos
      if unix_file?('/usr/bin/FastCli')
        output = @backend.run_command('FastCli -p 15 -c "show version | json"').stdout
        @platform[:name] = 'arista_eos_bash'
        family = 'fedora'
      else
        output = @backend.run_command('show version | json').stdout
      end

      unless output.empty?
        eos_ver = JSON.parse(output)
        @platform[:name] = @platform[:name] || 'arista_eos'
        family ||= 'arista_eos'
        @platform[:family] = family
        @platform[:release] = eos_ver['version']
        @platform[:arch] = eos_ver['architecture']
        true
      end
    end
  end
end
