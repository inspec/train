# encoding: utf-8
# author: Dominik Richter
# author: Christoph Hartmann
#
# Helper recipe to create create a few files in the operating
# systems, which the runner will test against.

gid = node['platform_family'] == 'aix' ? 'system' : node['root_group']

file '/tmp/file' do
  mode '0765'
  owner 'root'
  group gid
  content 'hello world'
end

file '/tmp/sfile' do
  mode '7765'
  owner 'root'
  group gid
  content 'hello suid/sgid/sticky'
end

directory '/tmp/folder' do
  mode '0567'
  owner 'root'
  group gid
end

link '/tmp/symlink' do
  to '/tmp/file'
  owner 'root'
  group gid
  mode '0777'
end

link '/usr/bin/allyourbase' do
  to '/usr/bin/sudo'
  owner 'root'
  group gid
  mode '0777'
end

execute 'create pipe/fifo' do
  command 'mkfifo /tmp/pipe'
  not_if 'test -e /tmp/pipe'
end

execute 'create block_device' do
  command "mknod /tmp/block_device b 7 7 && chmod 0666 /tmp/block_device && chown root:#{gid} /tmp/block_device"
  not_if 'test -e /tmp/block_device'
end
