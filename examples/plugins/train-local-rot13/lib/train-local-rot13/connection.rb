# Connection definition file for an example Train plugin.

# Most of the work of a Train plugin happens in this file.
# Connections derive from Train::Plugins::Transport::BaseConnection,
# and provide a variety of services.  Later generations of the plugin
# API will likely separate out these responsibilities, but for now,
# some of the responsibilities include:
# * authentication to the target
# * platform / release /family detection
# * caching
# * filesystem access
# * remote command execution
# * API execution
# * marshalling to / from JSON
# You don't have to worry about most of this.

# This allow us to inherit from Train::Plugins::Transport::BaseConnection
require 'train'

# Push platform detection out to a mixin, as it tends
# to develop at a different cadence than the rest
require 'train-local-rot13/platform'

# This is a support library for our file content meddling
require 'train-local-rot13/file_content_rotator'

# This is a support library for our command meddling
require 'mixlib/shellout'
require 'ostruct'

module TrainPlugins
  module LocalRot13
    # You must inherit from BaseConnection.
    class Connection < Train::Plugins::Transport::BaseConnection
      # We've placed platform detection in a separate module; pull it in here.
      include TrainPlugins::LocalRot13::Platform

      def initialize(options)
        # 'options' here is a hash, Symbol-keyed,
        # of what Train.target_config decided to do with the URI that it was
        # passed by `inspec -t` (or however the application gathered target information)
        # Some plugins might use this moment to capture credentials from the URI,
        # and the configure an underlying SDK accordingly.
        # You might also take a moment to manipulate the options.
        # Have a look at the Local, SSH, and AWS transports for ideas about what
        # you can do with the options.

        # Regardless, let the BaseConnection have a chance to configure itself.
        super(options)

        # If you need to attempt a connection to a remote system, or verify your
        # credentials, now is a good time.
      end

      # Filesystem access.
      # If your plugin is for an API, don't implement this.
      # If your plugin supports reading files, you'll need to implement this.
      def file_via_connection(path)
        train_file = Train::File::Local::Unix.new(self, path)
        # But then we wrap the return in a class that meddles with the content.
        FileContentRotator.new(train_file)
      end

      # Command execution.
      # If your plugin is for an API, don't implement this.
      # If your plugin supports executing commands, you'll need to implement this.
      def run_command_via_connection(cmd)
        # Run the command.
        run_result = Mixlib::ShellOut.new(cmd)
        run_result.run_command

        # Wrap the results in a structure that Train expects...
        OpenStruct.new(
          # And meddle with the stdout along the way.
          stdout: Rot13.rotate(run_result.stdout),
          stderr: run_result.stderr,
          exit_status: run_result.exitstatus,
        )
      end
    end
  end
end
