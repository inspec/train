# encoding: utf-8

require 'train/platforms/specs/os'
require 'train/platforms/detect/os_common'
require 'train/platforms/detect/os_local'

module Train::Platforms::Detect
  extend Train::Platforms::Detect::OSCommon
  extend Train::Platforms::Detect::OSLocal

  def self.scan(backend, local = false)
    @backend = backend
    @platform = {}

    # grab local platform info if we are running local
    if local == true
      @platform[:local] = true
      detect_local_os
    end

    # return the exact platform if we already know it
    return get_platform if @platform[:name]

    # Start at the top
    if @platform[:family]
      # go to the exact family if we already know it
      top = [Train::Platforms.list[@platform[:family]]]
    else
      top = Train::Platforms.top_platforms
    end

    top.each do |name, plat|
      puts "---> Testing: #{name} - #{plat.class}"
      if plat.detect
        result = instance_eval(&plat.detect)
        # if we have a match start looking at the children
        if result
          child_result = scan_children(plat)
          return child_result unless child_result.nil?
        end
      end
    end
    raise 'Sorry we did not find your platform'
  end

  def self.scan_children(parent)
    parent.children.each do |plat, condition|
      if condition
        condition.each do |k, v|
          return if @platform[k] != v
        end
      end
      unless plat.detect.nil?
        puts "---> Testing: #{plat.name} - #{plat.class}"
        result = instance_eval(&plat.detect)
        return get_platform if result && @platform[:name]
        child_result = scan_children(plat) unless plat.children.nil?
        return child_result unless child_result.nil?
      end
    end
    nil
  end

  def self.get_platform
    plat = Train::Platforms.list[@platform[:name]]
    plat.backend = @backend
    # this will just add all the platform info to the platform object as instance variables
    @platform.each { |name, value| plat.name = value unless name == 'name' }
    plat unless plat.nil?
  end
end
