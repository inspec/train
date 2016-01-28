# encoding: utf-8
# author: Dominik Richter
# author: Christoph Hartmann

module Train::Extras
  class LinuxFile < UnixFile
    def content
      return @content if defined?(@content)
      @content = @backend.run_command(
        "cat #{@spath} || echo -n").stdout
      return @content unless @content.empty?
      @content = nil if directory? or size.nil? or size > 0
      @content
    end
  end
end
