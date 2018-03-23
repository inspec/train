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
      validate_options(@options)
      @connection ||= Connection.new(@options)
    end

    class Connection < BaseConnection
      def initialize(options)
        super(options)

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

        @ssh = Net::SSH.start(
          @host,
          @user,
          @options.delete_if { |_key, value| value.nil? },
        )

        @channel ||= open_channel

        # Escalate privilege to enable mode if password is given
        if @enable_password
          run_command_via_channel("enable\r\n#{@enable_password}")
        end

        # Prevent `--MORE--` by removing terminal length limit
        run_command_via_channel('terminal length 0')

        @ssh
      end

      def run_command_via_connection(cmd)
        @session ||= establish_connection

        result = run_command_via_channel(cmd)
        CommandResult.new(*format_result(result))
      end

      def format_result(result)
        stderr_with_exit_1 = ['', result, 1]
        stdout_with_exit_0 = [result, '', 0]

        # IOS commands do not have an exit code, so we must capture known errors
        case result
        when /Bad IP address/
          stderr_with_exit_1
        when /Incomplete command/
          stderr_with_exit_1
        when /Invalid input detected/
          stderr_with_exit_1
        when /Unrecognized host/
          stderr_with_exit_1
        else
          stdout_with_exit_0
        end
      end

      def run_command_via_channel(cmd)
        # Ensure buffer is empty before sending data
        @buf = ''

        logger.debug("[SSH] Running `#{cmd}` on #{self}")
        @channel.send_data(cmd + "\r\n")

        logger.debug('[SSH] waiting for prompt')
        until @buf =~ @prompt
          raise BadEnablePassword if @buf =~ /Bad secrets/
          @channel.connection.process(0)
        end

        # Save the buffer and clear it for the next command
        output = @buf.dup
        @buf = ''

        format_output(output, cmd)
      end

      # The buffer (@buf) contains all data sent/received on the SSH channel so
      # we need to format the data to match what we would expect from Train
      def format_output(output, cmd)
        # Remove leading prompt
        output.sub!(/(\r\n|^)\S+[>#]/, '')

        # Remove command string
        output.sub!(/#{cmd}\r\n/, '')

        # Remove trailing prompt
        output.gsub!(/\S+[>#](\r\n|$)/, '')

        # Remove trailing returns/newlines
        output.gsub!(/(\r\n)+$/, '')

        output
      end

      # Create an SSH channel that writes to @buf when data is received
      def open_channel
        logger.debug("[SSH] opening SSH channel to #{self}")
        @ssh.open_channel do |ch|
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
