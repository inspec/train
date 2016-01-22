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
  puts "Use the following config: #{puts target_config}"

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

def print(data)
  puts data
end

# check local
local = get_os('local')
print(local)

# winrm over http
winrm = get_os('winrm', {
  target: ENV['train_target'],
  password: ENV['winrm_pass'],
  ssl: ENV['train_ssl'],
  self_signed: true,
})
print(winrm)
