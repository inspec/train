# encoding: utf-8

module Train
  class Platform
    include Train::Platforms::Common
    attr_accessor :condition, :families, :backend, :platform, :family_hierarchy

    def initialize(name, condition = {})
      @name = name
      @condition = condition
      @families = {}
      @family_hierarchy = []
      @platform = {}
      @detect = nil
      @title = name =~ /^[[:alpha:]]+$/ ? name.capitalize : name

      # add itself to the platform list
      Train::Platforms.list[name] = self
    end

    def direct_families
      @families.collect { |k, _v| k.name }
    end

    def name
      # Override here incase a updated name was set
      # during the detect logic
      @platform[:name] || @name
    end

    # This is for backwords compatability with
    # the current inspec os resource.
    def[](name)
      send(name)
    end

    def title(title = nil)
      return @title if title.nil?
      @title = title
      self
    end

    def to_hash
      @platform
    end

    # Add genaric family? and platform methods to an existing platform
    #
    # This is done later to add any custom
    # families/properties that were created
    def add_platform_methods
      family_list = Train::Platforms.families
      family_list.each_value do |k|
        next if respond_to?(k.name + '?')
        define_singleton_method(k.name + '?') {
          family_hierarchy.include?(k.name)
        }
      end

      # Helper methods for direct platform info
      @platform.each_key do |m|
        next if respond_to?(m)
        define_singleton_method(m) {
          @platform[m]
        }
      end

      # Create method for name if its not already true
      plat_name = name.downcase.tr(' ', '_') + '?'
      return if respond_to?(plat_name)
      define_singleton_method(plat_name) {
        true
      }
    end
  end
end
