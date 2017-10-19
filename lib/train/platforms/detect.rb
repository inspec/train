# encoding: utf-8

require 'train/platforms/specifications/os'
require 'train/platforms/detect/os_common'
require 'train/platforms/detect/os_local'

module Train::Platforms::Detect
  extend Train::Platforms::Detect::OSCommon
  extend Train::Platforms::Detect::OSLocal

  def self.scan(backend)
    @backend = backend
    @platform = {}

    # grab local platform info if we are running local
    if @backend.local?
      plat = detect_local_os
      return get_platform(plat) if plat
    end

    # Start at the top
    top = Train::Platforms.top_platforms
    top.each do |name, plat|
      puts "---> Testing-TOP: #{name} - #{plat.class}"
      if plat.detect
        result = instance_eval(&plat.detect)
        # if we have a match start looking at the children
        if result
          child_result = scan_children(plat)
          return child_result unless child_result.nil?
        end
      end
    end

    # raise Train::Exceptions::PlatformDetectionFailed 'Sorry we did not find your platform'
    raise 'Sorry we did not find your platform'
  end

  def self.scan_children(parent)
    parent.children.each do |plat, condition|
      if condition
        condition.each do |k, v|
          return nil if @platform[k] != v
        end
      end
      unless plat.detect.nil?
        puts "---> Testing: #{plat.name} - #{plat.class}"
        result = instance_eval(&plat.detect)
        return get_platform(plat) if result == true && plat.class == Train::Platform
        child_result = scan_children(plat) if plat.respond_to?(:children) && !plat.children.nil?
        return child_result unless child_result.nil?
      end
    end
    nil
  end

  def self.get_platform(plat)
    plat.backend = @backend
    plat.platform = @platform
    puts "---"
    puts plat.name
    puts plat.platform.inspect
    plat
  end
end
