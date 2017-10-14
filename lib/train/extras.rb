# encoding: utf-8
#
# Author:: Dominik Richter (<dominik.richter@gmail.com>)

module Train::Extras
  require 'train/extras/command_wrapper'
  require 'train/extras/file_common'
  require 'train/extras/file_unix'
  require 'train/extras/file_aix'
  require 'train/extras/file_qnx'
  require 'train/extras/file_linux'
  require 'train/extras/file_windows'
  require 'train/extras/os_common'
  require 'train/extras/stat'

  CommandResult = Struct.new(:stdout, :stderr, :exit_status)
  LoginCommand = Struct.new(:command, :arguments)
end
