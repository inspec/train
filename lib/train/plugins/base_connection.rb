# encoding: utf-8

require 'train/errors'
require 'train/extras'
require 'train/file'
require 'logger'

class Train::Plugins::Transport
  # A Connection instance can be generated and re-generated, given new
  # connection details such as connection port, hostname, credentials, etc.
  # This object is responsible for carrying out the actions on the remote
  # host such as executing commands, transferring files, etc.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  class BaseConnection
    include Train::Extras

    # Create a new Connection instance.
    #
    # @param options [Hash] connection options
    # @yield [self] yields itself for block-style invocation
    def initialize(options = nil)
      @options = options || {}
      @logger = @options.delete(:logger) || Logger.new(STDOUT)
      Train::Platforms::Detect::Specifications::OS.load
      Train::Platforms::Detect::Specifications::Api.load

      # default caching options
      @cache_enabled = {
        file: true,
        command: false,
      }

      @cache = {}
      @cache_enabled.each_key do |type|
        clear_cache(type)
      end
    end

    def cache_enabled?(type)
      @cache_enabled[type.to_sym]
    end

    # Enable caching types for Train. Currently we support
    # :file and :command types
    def enable_cache(type)
      fail Train::UnknownCacheType, "#{type} is not a valid cache type" unless @cache_enabled.keys.include?(type.to_sym)
      @cache_enabled[type.to_sym] = true
    end

    def disable_cache(type)
      fail Train::UnknownCacheType, "#{type} is not a valid cache type" unless @cache_enabled.keys.include?(type.to_sym)
      @cache_enabled[type.to_sym] = false
      clear_cache(type.to_sym)
    end

    # Closes the session connection, if it is still active.
    def close
      # this method may be left unimplemented if that is applicable
    end

    def to_json
      {
        'files' => Hash[@cache[:file].map { |x, y| [x, y.to_json] }],
      }
    end

    def load_json(j)
      require 'train/transports/mock'
      j['files'].each do |path, jf|
        @cache[:file][path] = Train::Transports::Mock::Connection::File.from_json(jf)
      end
    end

    # Is this a local transport?
    def local?
      false
    end

    def direct_platform(name, platform_details = nil)
      plat = Train::Platforms.name(name)
      plat.backend = self
      plat.platform = platform_details unless platform_details.nil?
      plat.family_hierarchy = family_hierarchy(plat).flatten
      plat.add_platform_methods
      plat
    end

    def family_hierarchy(plat)
      plat.families.each_with_object([]) do |(k, _v), memo|
        memo << k.name
        memo << family_hierarchy(k) unless k.families.empty?
      end
    end

    # Get information on the operating system which this transport connects to.
    #
    # @return [Platform] system information
    def platform
      @platform ||= Train::Platforms::Detect.scan(self)
    end
    # we need to keep os as a method for backwards compatibility with inspec
    alias os platform

    # This is the main command call for all connections. This will call the private
    # run_command_via_connection on the connection with optional caching
    def run_command(cmd)
      return run_command_via_connection(cmd) unless cache_enabled?(:command)

      @cache[:command][cmd] ||= run_command_via_connection(cmd)
    end

    # This is the main file call for all connections. This will call the private
    # file_via_connection on the connection with optional caching
    def file(path, *args)
      return file_via_connection(path, *args) unless cache_enabled?(:file)

      @cache[:file][path] ||= file_via_connection(path, *args)
    end

    # Builds a LoginCommand which can be used to open an interactive
    # session on the remote host.
    #
    # @return [LoginCommand] array of command line tokens
    def login_command
      fail NotImplementedError, "#{self.class} does not implement #login_command()"
    end

    # Block and return only when the remote host is prepared and ready to
    # execute command and upload files. The semantics and details will
    # vary by implementation, but a round trip through the hosted
    # service is preferred to simply waiting on a socket to become
    # available.
    def wait_until_ready
      # this method may be left unimplemented if that is applicablelog
    end

    private

    # Execute a command using this connection.
    #
    # @param command [String] command string to execute
    # @return [CommandResult] contains the result of running the command
    def run_command_via_connection(_command)
      fail NotImplementedError, "#{self.class} does not implement #run_command_via_connection()"
    end

    # Interact with files on the target. Read, write, and get metadata
    # from files via the transport.
    #
    # @param [String] path which is being inspected
    # @return [FileCommon] file object that allows for interaction
    def file_via_connection(_path, *_args)
      fail NotImplementedError, "#{self.class} does not implement #file_via_connection(...)"
    end

    def clear_cache(type)
      @cache[type.to_sym] = {}
    end

    # @return [Logger] logger for reporting information
    # @api private
    attr_reader :logger

    # @return [Hash] connection options
    # @api private
    attr_reader :options
  end
end
