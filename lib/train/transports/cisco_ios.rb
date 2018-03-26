# encoding: utf-8

require 'train/plugins'
require 'train/transports/ssh'

module Train::Transports
  class BadEnablePassword < Train::TransportError; end

  class CiscoIOS < SSH
    name 'cisco_ios'

    option :host, required: true
    option :user, required: true
    option :port, default: 22, required: true

    option :password, required: true

    # Used to elevate to enable mode (similar to `sudo su` in Linux)
    option :enable_password

    def connection
      @connection ||= Connection.new(validate_options(@options).options)
    end

    class Connection < BaseConnection
      def initialize(options)
        super(options)

        @session = nil
        @buf = nil

        # Delete options to avoid passing them in to `Net::SSH.start` later
        @host = @options.delete(:host)
        @user = @options.delete(:user)
        @port = @options.delete(:port)
        @enable_password = @options.delete(:enable_password)

        @prompt = /^\S+[>#]\r\n.*$/
      end

      def uri
        "ssh://#{@user}@#{@host}:#{@port}"
      end

      private

      def establish_connection
        logger.debug("[SSH] opening connection to #{self}")

        Net::SSH.start(
          @host,
          @user,
          @options.reject { |_key, value| value.nil? },
        )
      end

      def session
        return @session unless @session.nil?

        @session = open_channel(establish_connection)

        # Escalate privilege to enable mode if password is given
        if @enable_password
          run_command_via_connection("enable\r\n#{@enable_password}")
        end

        # Prevent `--MORE--` by removing terminal length limit
        run_command_via_connection('terminal length 0')

        @session
      end

      def run_command_via_connection(cmd)
        # Ensure buffer is empty before sending data
        @buf = ''

        logger.debug("[SSH] Running `#{cmd}` on #{self}")
        session.send_data(cmd + "\r\n")

        logger.debug('[SSH] waiting for prompt')
        until @buf =~ @prompt
          raise BadEnablePassword if @buf =~ /Bad secrets/
          session.connection.process(0)
        end

        # Save the buffer and clear it for the next command
        output = @buf.dup
        @buf = ''

        format_result(format_output(output, cmd))
      end

      ERROR_MATCHERS = [
        'Bad IP address',
        'Incomplete command',
        'Invalid input detected',
        'Unrecognized host',
      ].freeze

      # IOS commands do not have an exit code so we must compare the command
      # output with partial segments of known errors. Then, we return a
      # `CommandResult` with arguments in the correct position based on the
      # result.
      def format_result(result)
        if ERROR_MATCHERS.none? { |e| result.include?(e) }
          CommandResult.new(result, '', 0)
        else
          CommandResult.new('', result, 1)
        end
      end

      # The buffer (@buf) contains all data sent/received on the SSH channel so
      # we need to format the data to match what we would expect from Train
      def format_output(output, cmd)
        leading_prompt = /(\r\n|^)\S+[>#]/
        command_string = /#{cmd}\r\n/
        trailing_prompt = /\S+[>#](\r\n|$)/
        trailing_line_endings = /(\r\n)+$/

        output
          .sub(leading_prompt, '')
          .sub(command_string, '')
          .gsub(trailing_prompt, '')
          .gsub(trailing_line_endings, '')
      end

      # Create an SSH channel that writes to @buf when data is received
      def open_channel(ssh)
        logger.debug("[SSH] opening SSH channel to #{self}")
        ssh.open_channel do |ch|
          ch.on_data do |_, data|
            @buf += data
          end

          ch.send_channel_request('shell') do |_, success|
            raise 'Failed to open SSH shell' unless success
            logger.debug('[SSH] shell opened')
          end
        end
      end
    end
  end
end
