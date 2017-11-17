# encoding: utf-8

class Train::Plugins::Transport
  class CacheConnection < BaseConnection
    # Create a new CacheConnection instance. This instance will cache
    # file and command operations on the underline connection.
    #
    # @param connection [Connection] connection object
    def initialize(connection)
      @connection = connection
      @file_cache = {}
      @cmd_cache = {}

      @connection.class.instance_methods(false).each do |m|
        next if %i(run_command file).include?(m)
        define_singleton_method m do |*args|
          @connection.send(m, *args)
        end
      end
    end

    def file(path)
      if @file_cache.key?(path)
        @file_cache[path]
      else
        @file_cache[path] = @connection.file(path)
      end
    end

    def run_command(cmd)
      if @cmd_cache.key?(cmd)
        @cmd_cache[cmd]
      else
        @cmd_cache[cmd] = @connection.run_command(cmd)
      end
    end
  end
end
