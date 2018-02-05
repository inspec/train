# encoding: utf-8

require 'train/file/remote/unix'

module Train
  class File
    class Remote
      class Linux < Train::File::Remote::Unix
        def content
          return @content if defined?(@content)
          @content = @backend.run_command("cat #{@spath} || echo -n").stdout
          return @content unless @content.empty?
          @content = nil if directory? or size.nil? or size > 0
          @content
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
