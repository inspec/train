# encoding: utf-8
#
# Author:: Jared Quick

module Train::Platforms
  module Common

    # Add a family connection. This will create a family
    # if it does not exist and add a child relationship.
    def is_a(family)
      if self.class == Train::Platforms::Family && @name == family
        raise "Sorry you can not add a family inside itself '#{@name}.is_a(#{family})'"
      end

      # add family to the family list
      family = Train::Platforms.family(family)
      family.children[self] = @condition

      @families[family] = @condition
      @condition = nil
      self
    end

    def detect(&block)
      return @detect if block.nil?
      @detect = block
      self
    end

    def method_missing(m, *args, &block)
      unless args.empty?
        args = args.first if args.size == 1
        instance_variable_set("@#{m.to_s.chomp('=')}", args)
        self
      else
        instance_variable_get("@#{m}")
      end
    end
  end
end
