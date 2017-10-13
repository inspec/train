# encoding: utf-8

require 'train/platforms/specs/os'
require 'train/platforms/detect/os_common'

module Train::Platforms::Detect
  extend Train::Platforms::Detect::OSCommon

  def self.scan(backend)
    @backend = backend
    @platform = {}

    # Start at the top
    top = Train::Platforms.top_platforms

    top.each do |name, plat|
      puts "---> Testing: #{name} - #{plat.class}"
      if plat.detect
        result = instance_eval(&plat.detect)
        # if we have a match start looking at the children
        if result
          child_result = scan_children(plat)
          return child_result unless child_result.nil?
        end
      else
        warn "#{name} will not be evaluated as the detect block is not set" if plat.detect.nil?
      end
    end
    raise 'Sorry we did not find your platform'
  end

  def self.scan_children(parent)
    parent.children.each do |plat, condition|
      if condition
        # TODO: check condition vs @platform
      end
      unless plat.detect.nil?
        puts "---> Testing: #{plat.name} - #{plat.class}"
        result = instance_eval(&plat.detect)
        if result && plat.class == Train::Platform
          puts "FOUND One!!!"
          plat.backend = @backend
          # set all the info as part of the platform class
          @platform.each { |name, value| plat.name = value unless name == 'name'}
          return plat
        else
          child_result = scan_children(plat) unless plat.children.nil?
          return child_result unless child_result.nil?
        end
      else
        warn "#{plat.name} will not be evaluated as the detect block is not set" if plat.detect.nil?
      end
    end
    false
  end
end
