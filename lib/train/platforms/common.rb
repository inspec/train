# encoding: utf-8

module Train::Platforms
  module Common
    # Add a family connection. This will create a family
    # if it does not exist and add a child relationship.
    def in_family(family)
      if self.class == Train::Platforms::Family && @name == family
        raise "Unable to add family #{@name} to itself: '#{@name}.in_family(#{family})'"
      end

      # add family to the family list
      family = Train::Platforms.family(family)
      family.children[self] = @condition

      @families[family] = @condition
      @condition = nil
      self
    end

    def detect(&block)
      if block_given?
        @detect = block
        self
      elsif @detect.nil?
        # we are returning a block that just returns false here
        # to skip the family/platform evaluation if detect is not set
        ->(_) { false }
      else
        @detect
      end
    end
  end
end
