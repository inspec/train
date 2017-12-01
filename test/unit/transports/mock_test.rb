# encoding: utf-8
require 'helper'
require 'train/transports/mock'
require 'digest/sha2'

describe 'mock transport' do
  let(:transport) { Train::Transports::Mock.new(verbose: true) }
  let(:connection) { transport.connection }

  it 'can be instantiated' do
    transport.wont_be_nil
  end

  it 'can create a connection' do
    connection.wont_be_nil
  end

  it 'provides a uri' do
    connection.uri.must_equal 'mock://'
  end

  it 'provides a run_command_via_connection method' do
    methods = connection.class.private_instance_methods(false)
    methods.include?(:run_command_via_connection).must_equal true
  end

  it 'provides a file_via_connection method' do
    methods = connection.class.private_instance_methods(false)
    methods.include?(:file_via_connection).must_equal true
  end

  describe 'when running a mocked command' do
    let(:mock_cmd) {  }

    it 'has a simple mock command creator' do
      out = rand
      cls = Train::Transports::Mock::Connection::Command
      res = cls.new(out, '', 0)
      connection.mock_command('test', out).must_equal res
    end

    it 'handles nil commands' do
      connection.run_command(nil).stdout.must_equal('')
    end

    it 'can mock up nil commands' do
      out = rand
      connection.mock_command('', rand) # don't pull this result! always mock the input
      connection.mock_command(nil, out) # pull this result
      connection.run_command(nil).stdout.must_equal(out)
    end

    it 'gets results for stdout' do
      out = rand
      cmd = rand
      connection.mock_command(cmd, out)
      connection.run_command(cmd).stdout.must_equal(out)
    end

    it 'gets results for stderr' do
      err = rand
      cmd = rand
      connection.mock_command(cmd, nil, err)
      connection.run_command(cmd).stderr.must_equal(err)
    end

    it 'gets results for exit_status' do
      code = rand
      cmd = rand
      connection.mock_command(cmd, nil, nil, code)
      connection.run_command(cmd).exit_status.must_equal(code)
    end

    it 'can mock a command via its SHA2 sum' do
      out = rand.to_s
      cmd = rand.to_s
      shacmd = Digest::SHA256.hexdigest cmd
      connection.mock_command(shacmd, out)
      connection.run_command(cmd).stdout.must_equal(out)
    end
  end

  describe 'when accessing a mocked os' do
    it 'has the default mock os faily set to mock' do
      connection.os[:name].must_equal 'mock'
    end

    it 'sets the OS to the mocked value' do
      connection.mock_os({ name: 'centos', family: 'redhat' })
      connection.os.linux?.must_equal true
      connection.os.redhat?.must_equal true
      connection.os[:family].must_equal 'redhat'
    end

    it 'allows the setting of the name' do
      connection.mock_os({ name: 'foo' })
      connection.os[:name].must_equal 'foo'
    end

    it 'allows setting of the family' do
      connection.mock_os({ family: 'foo' })
      connection.os[:family].must_equal 'foo'
    end

    it 'allows setting of the release' do
      connection.mock_os({ release: '1.2.3' })
      connection.os[:release].must_equal '1.2.3'
    end

    it 'allows setting of the arch' do
      connection.mock_os({ arch: 'amd123' })
      connection.os[:arch].must_equal 'amd123'
    end

    it 'allow setting of multiple values' do
      connection.mock_os({ name: 'foo', family: 'bar' })
      connection.os[:name].must_equal 'foo'
      connection.os[:family].must_equal 'bar'
      connection.os[:arch].must_equal 'unknown'
      connection.os[:release].must_equal 'unknown'
    end

    it 'properly handles a nil value' do
      connection.mock_os(nil)
      connection.os[:name].must_equal 'mock'
      connection.os[:family].must_equal 'mock'
    end
  end

  describe 'when accessing a mocked file' do
    it 'handles a non-existing file' do
      x = rand.to_s
      f = connection.file(x)
      f.must_be_kind_of Train::Transports::Mock::Connection::File
      f.exist?.must_equal false
      f.path.must_equal x
    end

    # tests if all fields between the local json and resulting mock file
    # are equal
    JSON_DATA = Train.create('local').connection.file(__FILE__).to_json
    RES = Train::Transports::Mock::Connection::File.from_json(JSON_DATA)
    %w{ content mode owner group }.each do |f|
      it "can be initialized from json (field #{f})" do
        RES.method(f).call.must_equal JSON_DATA[f]
      end
    end
  end
end
