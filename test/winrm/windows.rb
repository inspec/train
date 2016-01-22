#!/usr/bin/env ruby
# encoding: utf-8
#
# Author:: Christoph Hartmann (<chris@lollyrock.com>)

require 'train'
require 'json'

# expects the following env variables
# export winrm_user=test_user
# export winrm_pass=Pass@word1
# export train_target='winrm://test_user@localhost:5985'
# export train_ssl='true'

def get_os(backend, opts = {})
  # resolve configuration
  target_config = Train.target_config(opts)
  puts "Use the following config: #{target_config}"

  # initialize train
  train = Train.create(backend, target_config)

  # start or reuse a connection
  conn = train.connection
  os = conn.os

  # get OS info
  conf = {
    name:    os[:name],
    family:  os[:family],
    release: os[:release],
    arch:    os[:arch],
  }

  # close the connection
  conn.close
  conf
end

def compare_hash(value, cmp)
  value == cmp
end

# check local
local = get_os('local')
puts "Detected the following OS (local): #{local}"

# winrm over http
winrm = get_os('winrm', {
  target: ENV['train_target'],
  password: ENV['winrm_pass'],
  ssl: ENV['train_ssl'],
  self_signed: true,
})
puts "Detected the following OS (remote): #{winrm}"

# compare values
cmp = {:name=>nil, :family=>"windows", :release=>"Server 2012 R2", :arch=>nil}
if !compare_hash(local, cmp) || !compare_hash(winrm, cmp)
  puts "Expected OS: #{cmp}"
  exit 1
end
