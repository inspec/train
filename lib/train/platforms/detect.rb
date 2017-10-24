# encoding: utf-8

require 'train/platforms/specifications/os'
require 'train/platforms/detect/os_common'

module Train::Platforms::Detect
  extend Train::Platforms::Detect::OSCommon

  # Main detect method to scan all platforms for a match
  #
  # @return Train::Platform instance or error if none found
  def self.scan(backend)
    @backend = backend
    @platform = {}
    @family_hierarchy = []

    # start with the platform/families who have no families (the top levels)
    top = Train::Platforms.top_platforms
    top.each do |name, plat|
      puts "---> Testing-TOP: #{name} - #{plat.class}"
      next unless plat.detect
      result = instance_eval(&plat.detect)
      next unless result == true

      # if we have a match start looking at the children
      plat_result = scan_children(plat)
      next if plat_result.nil?

      # return platform to backend
      @family_hierarchy << plat.name
      plat_result.family_hierarchy = @family_hierarchy
      return plat_result
    end

    raise Train::PlatformDetectionFailed, 'Sorry we did not find your platform'
  end

  def self.scan_children(parent)
    parent.children.each do |plat, condition|
      next if plat.detect.nil?
      puts "---> Testing: #{plat.name} - #{plat.class}"
      result = instance_eval(&plat.detect)
      next unless result == true

      if plat.class == Train::Platform
        @platform[:family] = parent.name
        return get_platform(plat) if condition.empty? || condition_check(condition)
      elsif plat.class == Train::Platforms::Family
        plat = scan_family_children(plat)
        return plat unless plat.nil?
      end
    end

    nil
  end

  def self.scan_family_children(plat)
    child_result = scan_children(plat) if !plat.children.nil?
    return if child_result.nil?
    @family_hierarchy << plat.name
    child_result
  end

  def self.check_condition(condition)
    condition.each do |k, v|
      return false unless instance_eval("#{@platform[k]} #{v}")
    end

    true
  end

  def self.get_platform(plat)
    plat.backend = @backend
    plat.platform = @platform
    Train::Platforms.add_platform_methods(plat)
    plat
  end
end
