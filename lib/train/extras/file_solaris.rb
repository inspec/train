# encoding: utf-8
# author: Dominik Richter
# author: Christoph Hartmann

module Train::Extras
  class SolarisFile < LinuxFile
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
  end
end
