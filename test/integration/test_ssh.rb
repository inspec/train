# encoding: utf-8
# author: Dominik Richter

require_relative 'helper'
require 'train'
require 'logger'

backends = {}
backend_conf = {
  'target'    => ENV['target']    || 'vagrant@localhost',
  'key_files' => ENV['key_files'] || '/root/.ssh/id_rsa',
  'logger'    => Logger.new(STDOUT),
}

backend_conf['target'] = 'ssh://' + backend_conf['target']
backend_conf['logger'].level = \
  if ENV.key?('debug')
    case ENV['debug'].to_s
    when /^false$/i, /^0$/i
      Logger::INFO
    else
      Logger::DEBUG
    end
  else
    Logger::INFO
  end

backends[:ssh] = proc { |*args|
  conf = Train.target_config(backend_conf)
  Train.create('ssh', conf).connection(args[0])
}

tests = ARGV

backends.each do |type, get_backend|
  tests.each do |test|
    instance_eval(File.read(test), test, 1)
  end
end
