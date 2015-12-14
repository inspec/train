# encoding: utf-8
# author: Dominik Richter
# author: Christoph Hartmann

require 'shellwords'
require 'train/extras/stat'

module Train::Extras
  class AixFile < LinuxFile

    def initialize(backend, path)
      super(backend, path)
    end

    def content
      return @content if defined?(@content)
      @content = @backend.run_command(
        "cat #{@spath} || echo -n").stdout
      return @content unless @content.empty?
      @content = nil if directory? or size.nil? or size > 0
      @content
    end

    def link_target
      return @link_target if defined? @link_target
      return @link_target = nil if link_path.nil?
      @link_target = @backend.file(link_path)
    end

    def link_path
      return nil unless symlink?
      @link_path ||= (
        @backend.run_command(
          "perl -e '$ln = readlink(shift) or exit 2; print $ln' #{@spath}"
        ).stdout
      )
    end

    def mounted?
      @mounted ||= (
        !@backend.run_command("mount | grep -- ' on #{@spath}'")
                 .stdout.empty?
      )
    end

    def product_version
      nil
    end

    def file_version
      nil
    end
  end
end
