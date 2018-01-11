
# encoding: utf-8

# rubocop:disable Style/Next
# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/PerceivedComplexity

module Train::Platforms::Detect::Specifications
  class Api
    def self.load
      plat = Train::Platforms

      plat.family('api')
      plat.family('cloud').in_family('api')
      plat.name('aws').in_family('cloud')
    end
  end
end
