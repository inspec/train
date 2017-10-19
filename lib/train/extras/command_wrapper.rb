# encoding: utf-8
# author: Dominik Richter
# author: Christoph Hartmann

require 'base64'
require 'train/errors'

module Train::Extras
  # Define the interface of all command wrappers.
  class CommandWrapperBase
    # Verify that the command wrapper is initialized properly and working.
    #
    # @return [Any] verification result, nil if all went well, otherwise a message
    def verify
      fail Train::ClientError, "#{self.class} does not implement #verify()"
    end

    # Wrap a command and return the augmented command which can be executed.
    #
    # @param [Strin] command that will be wrapper
    # @return [String] result of wrapping the command
    def run(_command)
      fail Train::ClientError, "#{self.class} does not implement #run(command)"
    end
  end

  # Wrap linux commands and add functionality like sudo.
  class LinuxCommand < CommandWrapperBase
    Train::Options.attach(self)

    option :shell, default: false
    option :shell_options, default: nil
    option :shell_command, default: nil
    option :sudo, default: false
    option :sudo_options, default: nil
    option :sudo_password, default: nil
    option :sudo_command, default: nil
    option :user

    def initialize(backend, options)
      @backend = backend
      validate_options(options)

      @shell = options[:shell]
      @shell_options = options[:shell_options] # e.g. '--login'
      @shell_command = options[:shell_command] # e.g. '/bin/sh'
      @sudo = options[:sudo]
      @sudo_options = options[:sudo_options]
      @sudo_password = options[:sudo_password]
      @sudo_command = options[:sudo_command]
      @user = options[:user]
    end

    # (see CommandWrapperBase::verify)
    def verify
      res = @backend.run_command(run('echo'))
      return nil if res.exit_status == 0
      rawerr = res.stdout + ' ' + res.stderr

      {
        'Sorry, try again' => 'Wrong sudo password.',
        'sudo: no tty present and no askpass program specified' =>
          'Sudo requires a password, please configure it.',
        'sudo: command not found' =>
          "Can't find sudo command. Please either install and "\
            'configure it on the target or deactivate sudo.',
        'sudo: sorry, you must have a tty to run sudo' =>
          'Sudo requires a TTY. Please see the README on how to configure '\
            'sudo to allow for non-interactive usage.',
      }.each do |sudo, human|
        rawerr = human if rawerr.include? sudo
      end

      rawerr
    end

    # (see CommandWrapperBase::run)
    def run(command)
      shell_wrap(sudo_wrap(command))
    end

    def self.active?(options)
      options.is_a?(Hash) && (
        options[:sudo] ||
        options[:shell]
      )
    end

    private

    # wrap the cmd in a sudo command
    def sudo_wrap(cmd)
      return cmd unless @sudo
      return cmd if @user == 'root'

      res = (@sudo_command || 'sudo') + ' '

      res = "#{safe_string(@sudo_password + "\n")} | #{res}-S " unless @sudo_password.nil?

      res << @sudo_options.to_s + ' ' unless @sudo_options.nil?

      res + cmd
    end

    # wrap the cmd in a subshell allowing for options to
    # passed to the subshell
    def shell_wrap(cmd)
      return cmd unless @shell

      shell = @shell_command || '$SHELL'
      options = ' ' + @shell_options.to_s unless @shell_options.nil?

      "#{safe_string(cmd)} | #{shell}#{options}"
    end

    # encapsulates encoding the string into a safe form, and decoding for use.
    # @return [String] A command line snippet that can be used as part of a pipeline.
    def safe_string(str)
      b64str = Base64.strict_encode64(str)
      "echo #{b64str} | base64 --decode"
    end
  end

  # this is required if you run locally on windows,
  # winrm connections provide a PowerShell shell automatically
  # TODO: only activate in local mode
  class PowerShellCommand < CommandWrapperBase
    Train::Options.attach(self)

    def initialize(backend, options)
      @backend = backend
      validate_options(options)
    end

    def run(script)
      # wrap the script to ensure we always run it via powershell
      # especially in local mode, we cannot be sure that we get a Powershell
      # we may just get a `cmd`.
      # TODO: we may want to opt for powershell.exe -command instead of `encodeCommand`
      "powershell -NoProfile -encodedCommand #{encoded(safe_script(script))}"
    end

    # suppress the progress stream from leaking to stderr
    def safe_script(script)
      "$ProgressPreference='SilentlyContinue';" + script
    end

    # Encodes the script so that it can be passed to the PowerShell
    # --EncodedCommand argument.
    # @return [String] The UTF-16LE base64 encoded script
    def encoded(script)
      encoded_script = safe_script(script).encode('UTF-16LE', 'UTF-8')
      Base64.strict_encode64(encoded_script)
    end

    def to_s
      'PowerShell CommandWrapper'
    end
  end

  class CommandWrapper
    include_options LinuxCommand

    def self.load(transport, options)
      if transport.os.unix?
        return nil unless LinuxCommand.active?(options)
        res = LinuxCommand.new(transport, options)
        msg = res.verify
        fail Train::UserError, "Sudo failed: #{msg}" unless msg.nil?
        res
      # only use powershell command for local transport. winrm transport
      # uses powershell as default
      elsif transport.os.windows? && transport.class == Train::Transports::Local::Connection
        PowerShellCommand.new(transport, options)
      end
    end
  end
end
