# encoding: utf-8

require 'train/file/remote/unix'

module Train
  class File
    class Remote
      class Aix < Train::File::Remote::Unix
        def link_path
          return nil unless symlink?
          @link_path ||=
            @backend.run_command("perl -e 'print readlink shift' #{@spath}").stdout.chomp
        end

        def shallow_link_path
          return nil unless symlink?
          @shallow_link_path ||=
            @backend.run_command("perl -e 'print readlink shift' #{@spath}").stdout.chomp
        end

        def mounted
          @mounted ||= @backend.run_command("lsfs -c #{@spath}")
        end

        def md5sum
          cmd = "md5sum #{path}"
          res = @backend.run_command(cmd)
          return res.stdout.split(' ').first if res.exit_status == 0

          raise_checksum_error(cmd, res)
        end

        def sha256sum
          cmd = "sha256sum #{@path}"
          res = @backend.run_command(cmd)
          return res.stdout.split(' ').first if res.exit_status == 0

          raise_checksum_error(cmd, res)
        end
      end
    end
  end
end
