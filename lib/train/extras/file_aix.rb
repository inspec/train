# encoding: utf-8

require 'shellwords'
require 'train/extras/stat'

module Train::Extras
  class AixFile < LinuxFile
    def content
      @content ||= case
                   when !exist?, directory?
                     nil
                   when size.nil?, size == 0
                     ''
                   else
                     @backend.run_command("cat #{@spath}").stdout || ''
                   end
    end

    def link_path
      return nil unless symlink?
      @link_path ||= (
        @backend.run_command("perl -e 'print readlink shift' #{@spath}").stdout.chomp
      )
    end

    def mounted
      @mounted ||= (
        @backend.run_command("lsfs -c #{@spath}")
      )
    end
  end
end
