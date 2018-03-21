# encoding: utf-8

require 'helper'
require 'train/transports/mock'
require 'securerandom'

class TestFile
  def initialize(string)
    @string = string
  end

  def exist?
    true
  end

  def size
    @string.length
  end

  def content
    @string
  end
end

describe 'uuid' do
  def mock_platform(name, commands = {}, files = {}, plat_options = {})
    Train::Platforms.list[name] = nil
    mock = Train::Transports::Mock::Connection.new
    commands.each do |command, data|
      mock.mock_command(command, data)
    end

    file_objects = {}
    files.each do |path, content|
      file_objects[path] = TestFile.new(content)
    end

    mock.files = file_objects
    mock.direct_platform(name, plat_options)
  end

  it 'finds a linux uuid from chef entity_uuid' do
    files = { '/var/chef/cache/data_collector_metadata.json' => '{"node_uuid":"d400073f-0920-41aa-8dd3-2ea59b18f5ce"}' }
    plat = mock_platform('linux', {}, files)
    plat.uuid.must_equal 'd400073f-0920-41aa-8dd3-2ea59b18f5ce'
  end

  it 'finds a windows uuid from chef entity_uuid' do
    ENV['SYSTEMDRIVE'] = 'C:'
    files = { 'C:\chef\cache\data_collector_metadata.json' => '{"node_uuid":"d400073f-0920-41aa-8dd3-2ea59b18f5ce"}' }
    plat = mock_platform('windows', {}, files)
    plat.uuid.must_equal 'd400073f-0920-41aa-8dd3-2ea59b18f5ce'
  end

  it 'finds a linux uuid from /etc/chef/chef_guid' do
    files = { '/etc/chef/chef_guid' => '5e430326-b5aa-56f8-975f-c3ca1c21df91' }
    plat = mock_platform('linux', {}, files)
    plat.uuid.must_equal '5e430326-b5aa-56f8-975f-c3ca1c21df91'
  end

  it 'finds a linux uuid from /home/testuser/.chef/chef_guid' do
    ENV['HOME'] = '/home/testuser'
    files = { '/home/testuser/.chef/chef_guid' => '5e430326-b5aa-56f8-975f-c3ca1c21df91' }
    plat = mock_platform('linux', {}, files)
    plat.uuid.must_equal '5e430326-b5aa-56f8-975f-c3ca1c21df91'
  end

  it 'finds a linux uuid from /etc/machine-id' do
    files = { '/etc/machine-id' => '123141dsfadf' }
    plat = mock_platform('linux', {}, files)
    plat.uuid.must_equal '5e430326-b5aa-56f8-975f-c3ca1c21df91'
  end

  it 'finds a linux uuid from /var/lib/dbus/machine-id' do
    files = {
      '/etc/machine-id' => '',
      '/var/lib/dbus/machine-id' => '123141dsfadf',
    }
    plat = mock_platform('linux', {}, files)
    plat.uuid.must_equal '5e430326-b5aa-56f8-975f-c3ca1c21df91'
  end

  it 'finds a linux uuid from /etc/machine-uuid' do
    files = { '/etc/machine-uuid' => 'd400073f-0920-41aa-8dd3-2ea59b18f5ce' }
    plat = mock_platform('linux', {}, files)
    plat.uuid.must_equal 'd400073f-0920-41aa-8dd3-2ea59b18f5ce'
  end

  it 'finds a linux uuid from uuid_command' do
    plat_options = { uuid_command: "system_profiler SPHardwareDataType | awk '/UUID/ { print $3; }'"}
    commands = { "system_profiler SPHardwareDataType | awk '/UUID/ { print $3; }'" => 'd400073f-0920-41aa-8dd3-2ea59b18f5ce' }
    plat = mock_platform('mac_os_x', commands, {}, plat_options)
    plat.uuid.must_equal '2ee3c95b-4023-570d-8177-f939901a3c51'
  end

  it 'finds a linux uuid from /etc/machine-id' do
    files = { '/etc/machine-id' => '123141dsfadf' }
    plat = mock_platform('linux', {}, files)
    plat.uuid.must_equal '5e430326-b5aa-56f8-975f-c3ca1c21df91'
  end

  it 'finds a windows uuid from wmic' do
    commands = { 'wmic csproduct get UUID' => "UUID\r\nd400073f-0920-41aa-8dd3-2ea59b18f5ce\r\n" }
    plat = mock_platform('windows', commands)
    plat.uuid.must_equal 'd400073f-0920-41aa-8dd3-2ea59b18f5ce'
  end

  it 'finds a windows uuid from registry' do
    commands = { '(Get-ItemProperty "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography" -Name "MachineGuid")."MachineGuid"' => "d400073f-0920-41aa-8dd3-2ea59b18f5ce\r\n" }
    plat = mock_platform('windows', commands)
    plat.uuid.must_equal 'd400073f-0920-41aa-8dd3-2ea59b18f5ce'
  end

  it 'finds a windows uuid from C:\chef\chef_guid' do
    ENV['HOMEDRIVE'] = 'C:\\'
    files = { 'C:\chef\chef_guid' => '5e430326-b5aa-56f8-975f-c3ca1c21df91' }
    plat = mock_platform('windows', {}, files)
    plat.uuid.must_equal '5e430326-b5aa-56f8-975f-c3ca1c21df91'
  end

  it 'finds a windows uuid from C:\Users\test\.chef\chef_guid' do
    ENV['HOMEDRIVE'] = 'C:\\'
    ENV['HOMEPATH'] = 'Users\test'
    files = { 'C:\Users\test\.chef\chef_guid' => '5e430326-b5aa-56f8-975f-c3ca1c21df91' }
    plat = mock_platform('windows', {}, files)
    plat.uuid.must_equal '5e430326-b5aa-56f8-975f-c3ca1c21df91'
  end


  it 'finds a windows uuid from C:\windows\machine-uuid' do
    ENV['SYSTEMROOT'] = 'C:\windows'
    files = { 'C:\windows\machine-uuid' => '5e430326-b5aa-56f8-975f-c3ca1c21df91' }
    plat = mock_platform('windows', {}, files)
    plat.uuid.must_equal '5e430326-b5aa-56f8-975f-c3ca1c21df91'
  end

  it 'finds a windows uuid from C:\Users\test\.system\machine-uuid' do
    ENV['HOMEDRIVE'] = 'C:\\'
    ENV['HOMEPATH'] = 'Users\test'
    files = { 'C:\Users\test\.system\machine-uuid' => '5e430326-b5aa-56f8-975f-c3ca1c21df91' }
    plat = mock_platform('windows', {}, files)
    plat.uuid.must_equal '5e430326-b5aa-56f8-975f-c3ca1c21df91'
  end

  it 'generates a uuid from a string' do
    plat = mock_platform('linux')
    uuid = Train::Platforms::Detect::UUID.new(plat)
    uuid.uuid_from_string('123141dsfadf').must_equal '5e430326-b5aa-56f8-975f-c3ca1c21df91'
  end

  it 'finds a aws uuid' do
    plat = mock_platform('aws')
    plat.backend.stubs(:unique_identifier).returns('158551926027')
    plat.uuid.must_equal '1d74ce61-ac15-5c48-9ee3-5aa8207ac37f'
  end

  it 'finds an azure uuid' do
    plat = mock_platform('azure')
    plat.backend.stubs(:unique_identifier).returns('1d74ce61-ac15-5c48-9ee3-5aa8207ac37f')
    plat.uuid.must_equal '2c2e4fa9-7287-5dee-85a3-6527face7b7b'
  end
end
