# encoding: utf-8
#
# Author:: Jared Quick

require 'train/platform/common'
require 'train/platform/info'
require 'train/platform/family'

module Train::Platform
  class << self
    # Retrieve the current family list, containing all family names
    # and their platform info objects.
    #
    # @return [Hash] map with family names and their children
    def list
      @list ||= {}
    end

    # This is a holding zone for platforms until they have a
    # proper family association
    def families
      @families ||= {}
    end
  end

  # Create or update a platform
  def self.name(name, condition = {})
    # Check the list to see if we already have one
    plat = Train::Platform.list[name]
    unless plat.nil?
      plat.condition = condition unless condition.nil?
      return plat
    end

    Train::Platform::Info.new(name, condition)
  end

  # Create or update a family
  def self.family(name, condition = {})
    # Check the families to see if we already have one
    family = Train::Platform.families[name]
    unless family.nil?
      family.condition = condition unless condition.nil?
      return family
    end

    Train::Platform::Family.new(name, condition)
  end

  def self.top_platforms
    top_platforms = families.select { |_key, value| value.families.empty? }
    top_platforms.merge!(list.select { |_key, value| value.families.empty? })
    top_platforms
  end

  def self.list_all
    top_platforms = self.top_platforms
    top_platforms.each_value do |platform|
      puts "#{platform.title} (#{platform.class})"
      print_children(platform) if defined?(platform.children)
    end
  end

  def self.print_children(parent, pad = 2)
    parent.children.each do |key, value|
      obj = key
      puts "#{' ' * pad}-> #{obj.title}#{value unless value.empty?}"
      print_children(obj, pad + 2) unless !defined?(obj.children) || obj.children.nil?
    end
  end

  require 'train/platform/specs/linux'
  def self.detect(backend)
    @backend = backend
    instance_eval(&Train::Platform.family('linux').detect)
    Train::Platform.name('ubuntu').backend = @backend
    Train::Platform.name('ubuntu').arch = 'unix'
    Train::Platform.name('ubuntu')
  end
end
