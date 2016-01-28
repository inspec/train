# encoding: utf-8
#
# Author:: Dominik Richter (<dominik.richter@gmail.com>)

module Train::Extras
  autoload :CommandWrapper, 'train/extras/command_wrapper'
  autoload :FileCommon,     'train/extras/file_common'
  autoload :AixFile,        'train/extras/file_aix'
  autoload :UnixFile,       'train/extras/file_unix'
  autoload :LinuxFile,      'train/extras/file_linux'
  autoload :WindowsFile,    'train/extras/file_windows'
  autoload :OSCommon,       'train/extras/os_common'
  autoload :Stat,           'train/extras/stat'

  CommandResult = Struct.new(:stdout, :stderr, :exit_status)
  LoginCommand = Struct.new(:command, :arguments)
end
