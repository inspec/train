# encoding: utf-8
# author: Dominik Richter
# author: Christoph Hartmann

require 'shellwords'
require 'train/extras/stat'

module Train::Extras
  class SolarisFile < LinuxFile
    def initialize(backend, path)
      super(backend, path)
    end

    def content
      return @content if defined?(@content)
      @content = case
                 when !exist?, directory?
                   nil
                 when size.nil?, size == 0
                   ''
                 else
                   @backend.run_command("cat #{@spath}").stdout || ''
                 end
    end
  end
end
