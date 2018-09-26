require 'train-test-fixture/platform'

module TrainPlugins
  module TestFixture
    class Connection < Train::Plugins::Transport::BaseConnection
      include TrainPlugins::TestFixture::Platform

      def initialize(options)
        super(options)
      end

    end
  end
end
