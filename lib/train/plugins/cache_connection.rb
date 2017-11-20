# encoding: utf-8

class Train::Plugins::Transport
  class CacheConnection
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
        clear_cache(type)
      end
    end

    def set_cache_status(type, status)
      @cache_enabled[type.to_sym] = status
    end

    def cache_enabled?(type)
      @cache_enabled[type.to_sym]
    end

    def clear_cache(type)
      @cache[type.to_sym] = {}
    end

    def file(path)
      @cache[:file][path] ||= @connection.file_via_connection(path)
    end

    def run_command(cmd)
      @cache[:command][cmd] ||= @connection.run_command_via_connection(cmd)
    end
  end
end
