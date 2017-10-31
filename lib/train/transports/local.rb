# encoding: utf-8
#
# author: Dominik Richter
# author: Christoph Hartmann

require 'train/plugins'
require 'mixlib/shellout'

module Train::Transports
  class Local < Train.plugin(1)
    name 'local'

    include_options Train::Extras::CommandWrapper

    def connection(_ = nil)
      @connection ||= Connection.new(@options)
    end

    class Connection < BaseConnection
      def initialize(options)
        super(options)
        @cmd_wrapper = nil
        @cmd_wrapper = CommandWrapper.load(self, options)
      end

      def run_command(cmd)
        cmd = @cmd_wrapper.run(cmd) unless @cmd_wrapper.nil?
        res = Mixlib::ShellOut.new(cmd)
        res.run_command
        CommandResult.new(res.stdout, res.stderr, res.exitstatus)
      rescue Errno::ENOENT => _
        CommandResult.new('', '', 1)
      end

      def local?
        true
      end

      def platform
        @platform ||= Train::Platforms::Detect.scan(self)
      end

      # we need to keep os as a method for backwards compatibility with inspec
      alias os platform

      def file(path)
        @files[path] ||= \
          if os.windows?
            Train::File::Local::Windows.new(self, path)
          else
            Train::File::Local::Unix.new(self, path)
          end
      end

      def login_command
        nil # none, open your shell
      end

      def uri
        'local://'
      end
    end
  end
end
