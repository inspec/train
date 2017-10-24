# encoding: utf-8

module Train
  class Platform
    include Train::Platforms::Common
    attr_accessor :name, :condition, :families, :backend, :platform, :family_hierarchy

    def initialize(name, condition = {})
      @condition = condition
      @name = name
      @families = {}
      @family_hierarchy = []

      # add itself to the platform list
      Train::Platforms.list[name] = self
    end

    def direct_families
      @families.collect { |k, _v| k.name }
    end

    # This is for backwords compatability with
    # the current inspec os resource.
    def[](name)
      send(name)
    end

    define_method "#{name}?" do |_arg = nil|
      true
    end

    def title(title = nil)
      if @title.nil? && title.nil?
        name.capitalize
      elsif title.nil?
        @title
      else
        @title = title
        self
      end
    end
  end
end
