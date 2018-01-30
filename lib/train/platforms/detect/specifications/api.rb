# encoding: utf-8

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
