# encoding: utf-8

require 'helper'
require 'train/transports/cisco_ios'

describe 'Train::Transports::CiscoIOS' do
  let(:cls) do
    plat = Train::Platforms.name('mock').in_family('cisco_ios')
    plat.add_platform_methods
    Train::Platforms::Detect.stubs(:scan).returns(plat)
    Train::Transports::CiscoIOS
  end

  let(:options) do
    {
      host: 'fakehost',
      user: 'fakeuser',
      password: 'fakepassword',
    }
  end

  let(:cisco_ios) do
    cls.new(options)
  end

  describe 'CiscoIOS::Connection' do
    let(:connection) { cls.new(options).connection }

    it 'raises an error when user is missing' do
      options.delete(:user)
      err = proc { cls.new(options).connection }.must_raise(Train::ClientError)
      err.message.must_match(/must provide.*user/)
    end

    it 'raises an error when host is missing' do
      options.delete(:host)
      err = proc { cls.new(options).connection }.must_raise(Train::ClientError)
      err.message.must_match(/must provide.*host/)
    end

    it 'raises an error when password is missing' do
      options.delete(:password)
      err = proc { cls.new(options).connection }.must_raise(Train::ClientError)
      err.message.must_match(/must provide.*password/)
    end

    it 'provides a uri' do
      connection.uri.must_equal 'ssh://fakeuser@fakehost:22'
    end
  end
end
