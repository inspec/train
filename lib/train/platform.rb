# encoding: utf-8

module Train
  class Platform
    include Train::Platforms::Common
    attr_accessor :name, :condition, :families, :backend, :platform

    def initialize(name, condition = {})
      @condition = condition
      @name = name
      @families = {}

      # add itself to the platform list
      Train::Platforms.list[name] = self
    end

    %w{unix? windows?}.each do |m|
      define_method m do |_arg = nil|
        @platform[:type] == m
      end
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
