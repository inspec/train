# encoding: utf-8

require 'shellwords'
require 'train/extras/stat'

module Train::Extras
  class AixFile < UnixFile
    def link_path
      return nil unless symlink?
      @link_path ||=
        @backend.run_command("perl -e 'print readlink shift' #{@spath}")
                .stdout.chomp
    end

    def mounted
      @mounted ||=
        @backend.run_command("lsfs -c #{@spath}")
    end
  end
end
