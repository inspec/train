# encoding: utf-8
# author: Brian Doody (HPE)
# This is heavily based on:
#
#   OHAI https://github.com/chef/ohai
#   by Adam Jacob, Chef Software Inc
#
require 'train/extras/uname'

module Train::Extras
  module DetectOpenVMS
    include Train::Extras::Uname

    def detect_openvms
      cmd = @backend.run_command('show system/noprocess')

      return false if cmd.exit_status != 0
      return false if cmd.stdout.empty?

      @platform[:name] = cmd.stdout.downcase.split(' ')[0]
      cmd = @backend.run_command('write sys$output f$getsyi("VERSION")')
      @platform[:release] = cmd.stdout.downcase.split("\n")[1][1..-1]
      cmd = @backend.run_command('write sys$output f$getsyi("ARCH_NAME")')
      @platform[:arch] = cmd.stdout.downcase.split("\n")[1]

      true
    end
  end
end
