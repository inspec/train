require 'train-test-fixture/version'

module TrainPlugins
  module TestFixture
    module Platform
      def platform
        force_platform!('test-fixture',
          release: TrainPlugins::TestFixture::VERSION,
          arch: 'mock',
        )
      end
    end
  end
end
