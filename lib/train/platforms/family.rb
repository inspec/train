# encoding: utf-8
#
# Author:: Jared Quick

module Train::Platforms
  class Family
    include Train::Platforms::Common
    attr_accessor :name, :condition, :families, :children

    def initialize(name, condition)
      @name = name
      @condition = {}
      @families = {}
      @children = {}

      # add itself to the families list
      Train::Platforms.families[@name.to_s] = self
    end

    def title(title = nil)
      if @title.nil? && title.nil?
        "#{name.capitalize} Family"
      elsif title.nil?
        @title
      else
        @title = title
        self
      end
    end
  end
end
