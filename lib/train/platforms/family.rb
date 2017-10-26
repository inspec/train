# encoding: utf-8

module Train::Platforms
  class Family
    include Train::Platforms::Common
    attr_accessor :name, :condition, :families, :children

    def initialize(name, condition)
      @name = name
      @condition = condition
      @families = {}
      @children = {}
      @detect = nil
      @title = name =~ /^[[:alpha:]]+$/ ? "#{name.capitalize} Family" : name

      # add itself to the families list
      Train::Platforms.families[@name.to_s] = self
    end

    def title(title = nil)
      return @title if title.nil?
      @title = title
      self
    end
  end
end
