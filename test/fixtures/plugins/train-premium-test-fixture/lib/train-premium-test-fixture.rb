module TrainPlugins
  module PremiumTestFixture
    class NonPremiumTransport < Train.plugin(1)
      name "premium-test-fixture"

      # Marker used by tests to prove this non-premium gem was loaded,
      # e.g. when the premium gem is unavailable.
      def self.premium?
        false
      end

      def connection(_ = nil)
        @connection
      end
    end
  end
end
