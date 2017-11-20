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
      @cacher = CacheConnection.new(self)
      Train::Platforms::Detect::Specifications::OS.load
    end

    def enable_cache(type)
      @cacher.set_cache_status(type, true)
    end

    def disable_cache(type)
      @cacher.set_cache_status(type, false)
      @cacher.clear_cache(type.to_sym)
    end

    # Closes the session connection, if it is still active.
    def close
      # this method may be left unimplemented if that is applicable
    end

    def to_json
      {
        'files' => Hash[@files.map { |x, y| [x, y.to_json] }],
      }
    end

    def load_json(j)
      require 'train/transports/mock'
      j['files'].each do |path, jf|
        @files[path] = Train::Transports::Mock::Connection::File.from_json(jf)
      end
    end

    # Is this a local transport?
    def local?
      false
    end

    # Get information on the operating system which this transport connects to.
    #
    # @return [Platform] system information
    def platform
      @platform ||= Train::Platforms::Detect.scan(self)
    end
    # we need to keep os as a method for backwards compatibility with inspec
    alias os platform

    # Execute a command using this connection.
    #
    # @param command [String] command string to execute
    # @return [CommandResult] contains the result of running the command
    def run_command_via_connection(_command)
      fail NotImplementedError, "#{self.class} does not implement #run_command_via_connection()"
    end

    # run command with optional caching
    def run_command(command)
      return @cacher.run_command(command) if @cacher.cache_enabled?(:command)

      run_command_via_connection(command)
    end

    # Interact with files on the target. Read, write, and get metadata
    # from files via the transport.
    #
    # @param [String] path which is being inspected
    # @return [FileCommon] file object that allows for interaction
    def file_via_connection(_path, *_args)
      fail NotImplementedError, "#{self.class} does not implement #file_via_connection(...)"
    end

    # file with optional caching
    def file(path, *args)
      return @cacher.file(path, *args) if @cacher.cache_enabled?(:file)

      file_via_connection(path, *args)
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

    # @return [Logger] logger for reporting information
    # @api private
    attr_reader :logger

    # @return [Hash] connection options
    # @api private
    attr_reader :options
  end
end
