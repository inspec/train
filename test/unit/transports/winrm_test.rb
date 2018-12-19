# encoding: utf-8

require 'helper'
require 'train/transports/winrm'

describe 'winrm transport' do
  let(:cls) do
    plat = Train::Platforms.name('mock').in_family('windows')
    plat.add_platform_methods
    Train::Platforms::Detect.stubs(:scan).returns(plat)
    Train::Transports::WinRM
  end
  let(:conf) {{
    host: rand.to_s,
    password: rand.to_s,
  }}
  let(:cls_agent) { cls.new({ host: rand.to_s }) }

  describe 'default options' do
    let(:winrm) { cls.new({ host: 'dummy' }) }

    it 'can be instantiated (with valid config)' do
      winrm.wont_be_nil
    end

    it 'configures the host' do
      winrm.options[:host].must_equal 'dummy'
    end

    it 'has default endpoint' do
      winrm.options[:endpoint].must_equal nil
    end

    it 'has default path set' do
      winrm.options[:path].must_equal '/wsman'
    end

    it 'has default ssl set' do
      winrm.options[:ssl].must_equal false
    end

    it 'has default self_signed set' do
      winrm.options[:self_signed].must_equal false
    end

    it 'has default rdp_port set' do
      winrm.options[:rdp_port].must_equal 3389
    end

    it 'has default winrm_transport set' do
      winrm.options[:winrm_transport].must_equal :negotiate
    end

    it 'has default winrm_disable_sspi set' do
      winrm.options[:winrm_disable_sspi].must_equal false
    end

    it 'has default winrm_basic_auth_only set' do
      winrm.options[:winrm_basic_auth_only].must_equal false
    end

    it 'has default user' do
      winrm.options[:user].must_equal 'administrator'
    end
  end

  describe 'winrm options' do
    let(:winrm) { cls.new(conf) }
    let(:connection) { winrm.connection }
    it 'without ssl genrates uri' do
      conf[:host] = 'dummy_host'
      connection.uri.must_equal 'winrm://administrator@http://dummy_host:5985/wsman:3389'
    end

    it 'without ssl genrates uri' do
      conf[:ssl] = true
      conf[:host] = 'dummy_host_ssl'
      connection.uri.must_equal 'winrm://administrator@https://dummy_host_ssl:5986/wsman:3389'
    end
  end

  describe 'options validation' do
    let(:winrm) { cls.new(conf) }
    it 'raises an error when a non-supported winrm_transport is specificed' do
      conf[:winrm_transport] = 'kerberos'
      proc { winrm.connection }.must_raise Train::ClientError
    end
  end
end
