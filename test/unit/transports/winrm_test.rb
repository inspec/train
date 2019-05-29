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
      winrm.options[:endpoint].must_be_nil
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
    it 'has default ca_trust_path set' do
      winrm.options.key?(:ca_trust_path).must_equal true
      winrm.options[:ca_trust_path].must_be_nil
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

  describe 'when configuring the connection' do
    let(:winrm) {
      cls.new(conf)
    }

    let(:conf) {{
      winrm_transport: :negotiate,
      host: rand.to_s,
      password: rand.to_s,
    }}

    def connection_option_value(name)
      winrm.send(:connection_options, conf)[name]
    end

    it "transport is configured as the correct symbol from provided value" do
      conf[:winrm_transport] = "testing"
      connection_option_value(:transport).must_equal conf[:winrm_transport].to_sym
    end

    it "ca_trust_path is configured from provided value" do
      conf[:ca_trust_path] = 'C:\some\path.pem'
      connection_option_value(:ca_trust_path).must_equal conf[:ca_trust_path]
    end
  end

  describe 'options validation' do
    let(:winrm) { cls.new(conf) }
    it 'raises an error when a non-supported winrm_transport is specificed' do
      conf[:winrm_transport] = 'invalid'
      proc { winrm.connection }.must_raise Train::ClientError
    end
  end
end
