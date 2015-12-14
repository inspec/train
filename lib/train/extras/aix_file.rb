# encoding: utf-8
# author: Dominik Richter
# author: Christoph Hartmann
# author: Jeremy Chalfant

require 'shellwords'
require 'train/extras/stat'

module Train::Extras
  class AixFile < LinuxFile

    def initialize(backend, path)
      super(backend, path)
    end

    def content
      return @content if defined?(@content)
      @content = @backend.run_command("cat #{@spath}").stdout || ''
      return @content unless @content.empty?
      @content = nil if directory? or size.nil? or size > 0
      @content
    end

    def link_path
      return nil unless symlink?
      @link_path ||= (
        @backend.run_command(
          "perl -e '$ln = readlink(shift) or exit 2; print $ln' #{@spath}"
        ).stdout
      )
    end
  end
end
