#
# Author:: Dominik Richter (<dominik.richter@gmail.com>)
# Author:: Christoph Hartmann (<chris@lollyrock.com>)

require "logger"
require_relative "../errors"
require_relative "../extras"
require_relative "../options"

class Train::Plugins
  class Transport
    include Train::Extras
    Train::Options.attach(self)

    require_relative "base_connection"

    # Initialize a new Transport object
    #
    # @param [Hash] config = nil the configuration for this transport
    # @return [Transport] the transport object
    def initialize(options = {})
      @options = merge_options({}, options || {})
      @logger = @options[:logger] || Logger.new($stdout, level: :fatal)
      # Validates audit log configuration options if audit log is enabled
      # The reason to implement different validate method for audit log options is
      # to validate only audit log options and not to break any existing validate_option implementation.
      if !options.empty? && @options[:enable_audit_log]
        validate_audit_log_options(options)
      end
    end

    # Create a connection to the target. Options may be provided
    # for additional configuration.
    #
    # @param [Hash] _options = nil provide optional configuration params
    # @return [Connection] the connection for this configuration
    def connection(_options = nil)
      raise Train::ClientError, "#{self.class} does not implement #connection()"
    end

    # Register the inheriting class with as a train plugin using the
    # provided name.
    #
    # @param [String] name of the plugin, by which it will be found
    def self.name(name)
      Train::Plugins.registry[name] = self
    end

    private

    # @return [Logger] logger for reporting information
    attr_reader :logger
  end
end
