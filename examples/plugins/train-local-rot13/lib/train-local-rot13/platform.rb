# Platform definition file.  This is a good place to separate out any
# logic regarding the identification of the OS or API at the far end
# of the connection.

# Abbreviate the namespace here, if you like.
module TrainPlugins::LocalRot13
  # Since we're mixing in the platform detection facility into Connection,
  # this has to come in as a Module.
  module Platform
    # The method `platform` is called when platform detection is
    # about to be performed.  Train core defines a sophisticated
    # system for platform detection, but for most plugins, you'll
    # only ever run on the special platform for which you are targeting.
    def platform
      # When you know you will only ever run on your dedicated platform
      # (for example, a plugin named train-aws would only run on the AWS
      # API, which we report as the 'aws' platform).
      # force_platform! lets you bypass platform detection.
      # The options to this are not currently documented completely.
      # Use release to report a version number.  You might use the version
      # of the plugin, or a version of an important underlying SDK, or a
      # version of a remote API.
      force_platform!('local-rot13', release: TrainPlugins::LocalRot13::VERSION)
    end
  end
end
