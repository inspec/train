# encoding: utf-8
#
# author: Christoph Hartmann
# author: Dominik Richter

require 'train/file/remote/unix'

module Train
  class File
    class Remote
      class Qnx < Train::File::Remote::Unix
        def content
          cat = 'cat'
          cat = '/proc/boot/cat' if @backend.os[:release].to_i >= 7
          @content ||= case
                       when !exist?
                         nil
                       else
                         @backend.run_command("#{cat} #{@spath}").stdout || ''
                       end
        end

        def type
          if @backend.run_command("file #{@spath}").stdout.include?('directory')
            return :directory
          else
            return :file
          end
        end

        %w{
          mode owner group uid gid mtime size selinux_label link_path mounted stat
        }.each do |field|
          define_method field.to_sym do
            fail NotImplementedError, "QNX does not implement the #{field}() method yet."
          end
        end
      end
    end
  end
end
