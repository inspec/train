# encoding: utf-8

require 'shellwords'
require 'train/extras/stat'

module Train
  class File
    class Local
      class Unix < Train::File::Local
        def sanitize_filename(path)
          @spath = Shellwords.escape(path) || @path
        end

        def stat
          return @stat if defined?(@stat)

          begin
            file_stat =
              if @follow_symlink
                ::File.stat(@path)
              else
                ::File.lstat(@path)
              end
          rescue StandardError => _err
            return @stat = {}
          end

          @stat = {
            type: Train::Extras::Stat.find_type(file_stat.mode),
            mode: file_stat.mode & 07777,
            mtime: file_stat.mtime.to_i,
            size: file_stat.size,
            owner: pw_username(file_stat.uid),
            uid: file_stat.uid,
            group: pw_groupname(file_stat.gid),
            gid: file_stat.gid,
          }

          lstat = @follow_symlink ? ' -L' : ''
          res = @backend.run_command("stat#{lstat} #{@spath} 2>/dev/null --printf '%C'")
          if res.exit_status == 0 && !res.stdout.empty? && res.stdout != '?'
            @stat[:selinux_label] = res.stdout.strip
          end

          @stat
        end

        def mounted
          @mounted ||=
            @backend.run_command("mount | grep -- ' on #{@path} '")
        end

        def grouped_into?(sth)
          group == sth
        end

        def unix_mode_mask(owner, type)
          o = UNIX_MODE_OWNERS[owner.to_sym]
          return nil if o.nil?

          t = UNIX_MODE_TYPES[type.to_sym]
          return nil if t.nil?

          t & o
        end

        def md5sum
          case @backend.os.family
          when 'darwin'
            # `-r` reverses output to match `md5sum`
            cmd = "md5 -r #{@path}"
          when 'solaris'
            cmd = "digest -a md5 #{@path}"
          else
            cmd = "md5sum #{@path}"
          end

          res = @backend.run_command(cmd)
          return res.stdout.split(' ').first if res.exit_status == 0

          raise_checksum_error(cmd, res)
        end

        def sha256sum
          case @backend.os.family
          when 'darwin', 'hpux'
            cmd = "shasum -a 256 #{@path}"
          when 'solaris'
            cmd = "digest -a sha256 #{@path}"
          else
            cmd = "sha256sum #{@path}"
          end

          res = @backend.run_command(cmd)
          return res.stdout.split(' ').first if res.exit_status == 0

          raise_checksum_error(cmd, res)
        end

        private

        def pw_username(uid)
          Etc.getpwuid(uid).name
        rescue ArgumentError => _
          nil
        end

        def pw_groupname(gid)
          Etc.getgrgid(gid).name
        rescue ArgumentError => _
          nil
        end

        UNIX_MODE_OWNERS = {
          all:   00777,
          owner: 00700,
          group: 00070,
          other: 00007,
        }.freeze

        UNIX_MODE_TYPES = {
          r: 00444,
          w: 00222,
          x: 00111,
        }.freeze
      end
    end
  end
end
