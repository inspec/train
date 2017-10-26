# encoding: utf-8

require 'train/platforms/specifications/os'
require 'train/platforms/detect/os_common'

module Train::Platforms::Detect
  class Scanner
    include Train::Platforms::Detect::OSCommon

    def initialize(backend)
      @backend = backend
      @platform = {}
      @family_hierarchy = []

      # detect cache variables
      @files = {}
      @uname = {}
      @lsb = {}
    end

    # Main detect method to scan all platforms for a match
    #
    # @return Train::Platform instance or error if none found
    def scan
      # start with the platform/families who have no families (the top levels)
      top = Train::Platforms.top_platforms
      top.each do |name, plat|
        next unless plat.detect
        result = instance_eval(&plat.detect)
        next unless result == true

        # if we have a match start looking at the children
        plat_result = scan_children(plat)
        next if plat_result.nil?

        # return platform to backend
        @family_hierarchy << plat.name
        return get_platform(plat_result)
      end

      raise Train::PlatformDetectionFailed, 'Sorry we did not find your platform'
    end

    def scan_children(parent)
      parent.children.each do |plat, condition|
        next if plat.detect.nil?
        result = instance_eval(&plat.detect)
        next unless result == true

        if plat.class == Train::Platform
          @platform[:family] = parent.name
          return plat if condition.empty? || check_condition(condition)
        elsif plat.class == Train::Platforms::Family
          plat = scan_family_children(plat)
          return plat unless plat.nil?
        end
      end

      nil
    end

    def scan_family_children(plat)
      child_result = scan_children(plat) if !plat.children.nil?
      return if child_result.nil?
      @family_hierarchy << plat.name
      child_result
    end

    def check_condition(condition)
      condition.each do |k, v|
        opp, expected = v.strip.split(' ')
        opp = '==' if opp == '='
        return false if @platform[k].nil? || !instance_eval("'#{@platform[k]}' #{opp} '#{expected}'")
      end

      true
    end

    def get_platform(plat)
      plat.backend = @backend
      plat.platform = @platform
      plat.add_platform_methods
      plat.family_hierarchy = @family_hierarchy
      plat
    end
  end
end
