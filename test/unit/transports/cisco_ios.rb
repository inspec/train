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

  let(:opts) do
    {
      host: 'fakehost',
      user: 'fakeuser',
      password: 'fakepassword',
    }
  end

  let(:cisco_ios) do
    cls.new(opts)
  end

  describe 'CiscoIOS::Connection' do
    let(:connection) { cls.new(opts).connection }

    describe '#initialize' do
      it 'raises an error when user is missing' do
        opts.delete(:user)
        err = proc { cls.new(opts).connection }.must_raise(Train::ClientError)
        err.message.must_match(/must provide.*user/)
      end

      it 'raises an error when host is missing' do
        opts.delete(:host)
        err = proc { cls.new(opts).connection }.must_raise(Train::ClientError)
        err.message.must_match(/must provide.*host/)
      end

      it 'raises an error when password is missing' do
        opts.delete(:password)
        err = proc { cls.new(opts).connection }.must_raise(Train::ClientError)
        err.message.must_match(/must provide.*password/)
      end

      it 'provides a uri' do
        connection.uri.must_equal 'ssh://fakeuser@fakehost:22'
      end
    end

    describe '#format_result' do
      it 'returns correctly when result is `good`' do
        connection.send(:format_result, 'good').must_equal ['good', '', 0]
      end

      it 'returns correctly when result matches /Bad IP address/' do
        output = "Translating \"nope\"\r\n\r\nTranslating \"nope\"\r\n\r\n% Bad IP address or host name\r\n% Unknown command or computer name, or unable to find computer address\r\n"
        result = connection.send(:format_result, output)
        result.must_equal ['', output, 1]
      end

      it 'returns correctly when result matches /Incomplete command/' do
        output = "% Incomplete command.\r\n\r\n"
        result = connection.send(:format_result, output)
        result.must_equal ['', output, 1]
      end

      it 'returns correctly when result matches /Invalid input detected/' do
        output = "             ^\r\n% Invalid input detected at '^' marker.\r\n\r\n"
        result = connection.send(:format_result, output)
        result.must_equal ['', output, 1]
      end

      it 'returns correctly when result matches /Unrecognized host/' do
        output = "Translating \"nope\"\r\n% Unrecognized host or address, or protocol not running.\r\n\r\n"
        result = connection.send(:format_result, output)
        result.must_equal ['', output, 1]
      end
    end

    describe '#format_output' do
      it 'returns output containing only the output of the command executed' do
        cmd = 'show calendar'
        output = "show calendar\r\n10:35:50 UTC Fri Mar 23 2018\r\n7200_ios_12#\r\n7200_ios_12#"
        result = connection.send(:format_output, output, cmd)
        result.must_equal '10:35:50 UTC Fri Mar 23 2018'
      end
    end
  end
end
