module TrainPlugins
  module PremiumTestFixture
    class PremiumTransport < Train.plugin(1)
      name "premium-test-fixture"

      # Marker used by tests to prove the premium gem was the one loaded,
      # instead of the core transport or the non-premium gem.
      def self.premium?
        true
      end

      def connection(_ = nil)
        @connection
      end
    end
  end
end
