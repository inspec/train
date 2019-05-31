# encoding: utf-8
#
# Author:: Dominik Richter (<dominik.richter@gmail.com>)

module Train::Extras
  require "train/extras/command_wrapper"
  require "train/extras/stat"

  CommandResult = Struct.new(:stdout, :stderr, :exit_status)
  LoginCommand = Struct.new(:command, :arguments)
end
