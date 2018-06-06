# encoding: utf-8

require 'helper'

describe 'oneview transport' do

  let(:settings_file_default) do
    require 'tempfile'
    file = Tempfile.new('inspec_settings')
    info = <<-INFO
{
    "url": "https://192.168.0.1",
    "user": "oneviewuser",
    "password": "NotArealPa$$word!",
    "api_version": 300
}
    INFO
    file.write(info)
    file.close
    file
  end

  let(:settings_file_override) do
    require 'tempfile'
    file = Tempfile.new('inspec_settings_override')
    info = <<-INFO
{
    "url": "https://123.45.67.89",
    "user": "administrator",
    "password": "An0therFakePa$$!!",
    "api_version": 200
}
    INFO
    file.write(info)
    file.close
    file
  end

  def transport(options = nil)
    ENV['INSPEC_ONEVIEW_SETTINGS'] = settings_file_default.path
    ENV['ONEVIEW_RESOURCE_NAME'] = 'oneview_resource_name'
    ENV['ONEVIEW_RESOURCE_TYPE'] = 'oneview_resource_type'
    require 'train/transports/oneview'
    Train::Transports::Oneview.new(options)
  end

  let(:connection) { transport.connection }
  let(:options) { connection.instance_variable_get(:@options) }
  let(:cache) { connection.instance_variable_get(:@cache) }

  describe 'options' do
    it 'defaults to env options' do
      options[:oneview_settings_file] = settings_file_default.path
      options[:name].must_equal 'oneview_resource_name'
      options[:type].must_equal 'oneview_resource_type'
    end
  end

  it 'allows for options override' do
    transport = transport(oneview_settings_file: settings_file_override.path, name: "override_name", type: "override_type")
    options = transport.connection.instance_variable_get(:@options)
    options[:oneview_settings_file].must_equal settings_file_override.path
    options[:name].must_equal "override_name"
    options[:type].must_equal "override_type"
  end

  describe 'platform' do
    it 'returns platform' do
      platform = connection.platform
      platform.name.must_equal 'oneview'
      platform.family_hierarchy.must_equal ['iaas', 'api']
    end
  end

  # Can't test oneview_client as the OneviewSDK hits the supplied fake url and incurs a timeout
  #
  # describe 'oneview_client' do
  #   it 'test oneview_client with caching' do
  #     client = connection.oneview_client
  #     client.is_a?(Object).must_equal true
  #     cache[:api_call].count.must_equal 1
  #   end
  #
  #   it 'test oneview_client without caching' do
  #     connection.disable_cache(:api_call)
  #     client = connection.oneview_client
  #     client.is_a?(Object).must_equal true
  #     cache[:api_call].count.must_equal 0
  #   end
  # end

  # test resources fails if options are nil
  describe 'resources' do
    it 'raises an error with nil arguments' do
      options[:name]=nil
      options[:type]=nil
      connection.connect
      proc { connection.resources }.must_raise RuntimeError
    end
  end

  # test config is correctly returned from OneviewSDK
  describe 'config' do
    it 'defaults to env option supplied config' do
      params = transport.connection.config
      params["url"].must_equal "https://192.168.0.1"
      params["user"].must_equal "oneviewuser"
      params["password"].must_equal "NotArealPa$$word!"
      params["api_version"].must_equal 300
    end
    it 'updates when settings are supplied as options' do
      transport = transport(oneview_settings_file: settings_file_override.path)
      params = transport.connection.config
      params["url"].must_equal "https://123.45.67.89"
      params["user"].must_equal "administrator"
      params["password"].must_equal "An0therFakePa$$!!"
      params["api_version"].must_equal 200
    end
  end

  # test options override of env vars in connect
  describe 'connect' do
    let(:connect_settings) do
      require 'tempfile'
      file = Tempfile.new('connnect_settings')
      info = <<-INFO
{
    "url": "https://987.65.43.21",
    "user": "anotheruser",
    "password": "YetAn0therFakePa$$!!",
    "api_version": 300
}
      INFO
      file.write(info)
      file.close
      file
    end
    it 'validate oneview connection with supplied settings' do
      options[:oneview_settings_file] = connect_settings.path
      connection.connect
      ENV['INSPEC_ONEVIEW_SETTINGS'].must_equal connect_settings.path
    end
    it 'validate oneview connection with supplied name' do
      options[:name] = 'supplied_name'
      connection.connect
      ENV['ONEVIEW_RESOURCE_NAME'].must_equal 'supplied_name'
    end
    it 'validate oneview connection with supplied type' do
      options[:type] = 'supplied_type'
      connection.connect
      ENV['ONEVIEW_RESOURCE_TYPE'].must_equal 'supplied_type'
    end
  end

  describe 'unique_identifier' do
    it 'test connection unique identifier' do
      client = connection
      client.unique_identifier.must_equal 'oneviewuser@192.168.0.1'
    end
  end

  describe 'uri' do
    it 'test uri' do
      client = connection
      client.uri.must_equal 'oneview://oneviewuser@192.168.0.1'
    end
    it 'test uri with supplied settings' do
      transport = transport(oneview_settings_file: settings_file_override.path)
      transport.connection.uri.must_equal 'oneview://administrator@123.45.67.89'
    end
  end
end