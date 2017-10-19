# encoding: utf-8
#
# Author:: Jared Quick

module Train::Platforms
  module Common

    # Add a family connection. This will create a family
    # if it does not exist and add a child relationship.
    def in_family(family)
      if self.class == Train::Platforms::Family && @name == family
        raise "Sorry you can not add a family inside itself '#{@name}.in_family(#{family})'"
      end

      # add family to the family list
      family = Train::Platforms.family(family)
      family.children[self] = @condition

      @families[family] = @condition
      @condition = nil
      self
    end

    def detect(&block)
      return @detect unless block_given?
      @detect = block
      self
    end
  end
end
