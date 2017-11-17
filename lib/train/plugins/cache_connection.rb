# encoding: utf-8

class Train::Plugins::Transport
  class CacheConnection
    attr_accessor :cache_enabled
    # Create a new CacheConnection instance. This instance will cache
    # file and command operations on the underline connection.
    #
    # @param connection [Connection] connection object
    def initialize(connection)
      @connection = connection
      @cache = {}

      # default caching options
      @cache_enabled = {
        file: true,
        command: false,
      }

      @cache_enabled.each_key do |type|
        @cache[type] = {}
      end
    end

    def clear_cache(type)
      @cache[type.to_sym] = {}
    end

    def file(path)
      if @cache[:file].key?(path)
        @cache[:file][path]
      else
        @cache[:file][path] = @connection.file_via_connection(path)
      end
    end

    def run_command(cmd)
      if @cache[:command].key?(cmd)
        @cache[:command][cmd]
      else
        @cache[:command][cmd] = @connection.run_command_via_connection(cmd)
      end
    end
  end
end
