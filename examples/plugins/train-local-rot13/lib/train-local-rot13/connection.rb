require 'train-local-rot13/platform'

module TrainPlugins
  module LocalRot13
    class Connection < Train::Plugins::Transport::BaseConnection

      def initialize(options)
        # 'options' here is a hash, Symbol-keyed,
        # of what Train.target_config decided to do with the URI that it was
        # passed by `inspec -t`
        # Some plugins might use this moment to capture credentials from the URI,
        # and the configure an underlying SDK accordingly.

        # Regardless, let the BaseConnection have a chance to configure itself.
        super(options)
      end
    end

  end
end
