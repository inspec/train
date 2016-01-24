# encoding: utf-8
# author: Christoph Hartmann
# author: Dominik Richter

require 'minitest/autorun'
require 'minitest/spec'
require 'mocha/setup'
require 'train'

describe 'windows local command' do
  let(:conn) {
    # get final config
    target_config = Train.target_config({
      target: ENV['train_target'],
      password: ENV['winrm_pass'],
      ssl: ENV['train_ssl'],
      self_signed: true,
    })

    # initialize train
    backend = Train.create('winrm', target_config)

    # start or reuse a connection
    conn = backend.connection
    conn
  }

  it 'verify os' do
    os = conn.os
    os[:name].must_equal nil
    os[:family].must_equal "windows"
    os[:release].must_equal "Server 2012 R2"
    os[:arch].must_equal nil
  end

  after do
    # close the connection
    conn.close
  end
end
