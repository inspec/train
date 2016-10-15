# encoding: utf-8
#
# Author:: Dominik Richter (<dominik.richter@gmail.com>)
require 'helper'

describe Train do
  before do
    Train::Plugins.registry.clear
  end

  describe '#create' do
    it 'raises an error if the plugin isnt found' do
      proc { Train.create('missing') }.must_raise Train::UserError
    end

    it 'load a plugin if it isnt in the registry yet via symbol' do
      Kernel.stub :require, true do
        ex = Class.new(Train.plugin 1) { name 'existing' }
        train = Train.create(:existing)
        train.class.must_equal ex
      end
    end

    it 'load a plugin if it isnt in the registry yet via string' do
      Kernel.stub :require, true do
        ex = Class.new(Train.plugin 1) { name 'existing' }
        train = Train.create('existing')
        train.class.must_equal ex
      end
    end
  end

  describe '#options' do
    it 'raises exception if a given transport plugin isnt found' do
      proc { Train.options('missing') }.must_raise Train::UserError
    end

    it 'provides empty options of a transport plugin' do
      Class.new(Train.plugin 1) { name 'none' }
      Train.options('none').must_equal({})
    end

    it 'provides all options of a transport plugin' do
      Class.new(Train.plugin 1) {
        name 'one'
        option :one, required: true, default: 123
      }
      Train.options('one').must_equal({
        one: {
          required: true,
          default: 123,
        }
      })
    end
  end

  describe '#target_config' do
    it 'configures resolves target' do
      org = {
        target: 'ssh://user:pass@host.com:123/path',
      }
      res = Train.target_config(org)
      res[:backend].must_equal 'ssh'
      res[:host].must_equal 'host.com'
      res[:user].must_equal 'user'
      res[:password].must_equal 'pass'
      res[:port].must_equal 123
      res[:target].must_equal org[:target]
      res[:path].must_equal '/path'
      org.keys.must_equal [:target]
    end

    it 'resolves a target while keeping existing fields' do
      org = {
        target:   'ssh://user:pass@host.com:123/path',
        backend:  rand,
        host:     rand,
        user:     rand,
        password: rand,
        port:     rand,
        path:     rand
      }
      res = Train.target_config(org)
      res.must_equal org
    end

    it 'resolves a winrm target' do
      org = {
        target:   'winrm://Administrator@192.168.10.140',
        backend:  'winrm',
        host:     '192.168.10.140',
        user:     'Administrator',
        password: nil,
        port:     nil,
        path:     nil
      }
      res = Train.target_config(org)
      res.must_equal org
    end

    it 'keeps the configuration when incorrect target is supplied' do
      org = {
        target: 'wrong',
      }
      res = Train.target_config(org)
      res[:backend].must_be_nil
      res[:host].must_be_nil
      res[:user].must_be_nil
      res[:password].must_be_nil
      res[:port].must_be_nil
      res[:path].must_be_nil
      res[:target].must_equal org[:target]
    end

    it 'always takes ruby sumbols as configuration fields' do
      org = {
        'target'    => 'ssh://user:pass@host.com:123/path',
        'backend'   => rand,
        'host'      => rand,
        'user'      => rand,
        'password'  => rand,
        'port'      => rand,
        'path'      => rand
      }
      nu = org.each_with_object({}) { |(x, y), acc|
        acc[x.to_sym] = y; acc
      }
      res = Train.target_config(org)
      res.must_equal nu
    end

    it 'supports empty URIs with schema://' do
      org = { target: 'mock://' }
      res = Train.target_config(org)
      res[:backend].must_equal 'mock'
      res[:host].must_be_nil
      res[:user].must_be_nil
      res[:password].must_be_nil
      res[:port].must_be_nil
      res[:path].must_be_nil
      res[:target].must_equal org[:target]
    end

    it 'supports empty URIs with schema:' do
      org = { target: 'mock:' }
      res = Train.target_config(org)
      res[:backend].must_equal 'mock'
      res[:host].must_be_nil
      res[:user].must_be_nil
      res[:password].must_be_nil
      res[:port].must_be_nil
      res[:path].must_be_nil
      res[:target].must_equal org[:target]
    end

    it 'it raises UserError on invalid URIs' do
      org = { target: 'mock world' }
      proc { Train.target_config(org) }.must_raise Train::UserError
    end
  end

  describe '#validate_backend' do
    it 'just returns the backend if it is provided' do
      x = rand
      Train.validate_backend({ backend: x }).must_equal x
    end

    it 'returns the local backend if nothing was provided' do
      Train.validate_backend({}).must_equal :local
    end

    it 'returns the default backend if nothing was provided' do
      x = rand
      Train.validate_backend({}, x).must_equal x
    end

    it 'fails if no backend was given but a target is provided' do
      proc { Train.validate_backend({ target: rand }) }.must_raise Train::UserError
    end

    it 'fails if no backend was given but a host is provided' do
      proc { Train.validate_backend({ host: rand }) }.must_raise Train::UserError
    end
  end
end
