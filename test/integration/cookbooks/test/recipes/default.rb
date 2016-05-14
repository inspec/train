# encoding: utf-8
# author: Dominik Richter
#
# Helper recipe to create create a few files in the operating
# systems, which the runner will test against.
# It also initializes the runner inside the machines
# and makes sure all dependencies are ready to go.
#
# Finally (for now), it actually executes the all tests with
# the local execution backend

include_recipe('test::prep_files')

# prepare ssh for backend
execute 'create ssh key' do
  command 'ssh-keygen -t rsa -b 2048 -f /root/.ssh/id_rsa -N ""'
  not_if 'test -e /root/.ssh/id_rsa'
end

execute 'add ssh key to vagrant user' do
  command 'cat /root/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys'
end

execute 'test ssh connection' do
  command 'ssh -o StrictHostKeyChecking=no -i /root/.ssh/id_rsa vagrant@localhost "echo 1"'
end

# prepare a few users
%w{ nopasswd passwd nosudo reqtty customcommand }.each do |name|
  user name do
    password '$1$7MCNTXPI$r./jqCEoVlLlByYKSL3sZ.'
    manage_home true
  end
end

%w{nopasswd vagrant}.each do |name|
  sudo name do
    user '%'+name
    nopasswd true
    defaults ['!requiretty']
  end
end

sudo 'passwd' do
  user 'passwd'
  nopasswd false
  defaults ['!requiretty']
end

sudo 'reqtty' do
  user 'reqtty'
  nopasswd true
  defaults ['requiretty']
end

sudo 'customcommand' do
  user 'customcommand'
  nopasswd true
  defaults ['!requiretty']
end

# execute tests
execute 'bundle install' do
  command '/opt/chef/embedded/bin/bundle install --without integration tools'
  cwd '/tmp/kitchen/data'
end

execute 'run local tests' do
  command '/opt/chef/embedded/bin/ruby -I lib test/integration/test_local.rb test/integration/tests/*_test.rb'
  cwd '/tmp/kitchen/data'
end

execute 'run ssh tests' do
  command '/opt/chef/embedded/bin/ruby -I lib test/integration/test_ssh.rb test/integration/tests/*_test.rb'
  cwd '/tmp/kitchen/data'
end

%w{passwd nopasswd reqtty customcommand}.each do |name|
  execute "run local sudo tests as #{name}" do
    command "/opt/chef/embedded/bin/ruby -I lib test/integration/sudo/#{name}.rb"
    cwd '/tmp/kitchen/data'
    user name
  end
end

execute 'fix sudoers for reqtty' do
  command 'chef-apply contrib/fixup_requiretty.rb'
  cwd '/tmp/kitchen/data'
  environment(
    'TRAIN_SUDO_USER' => 'reqtty',
    'TRAIN_SUDO_VERY_MUCH' => 'yes',
  )
end

# if it's fixed, it should behave like user 'nopasswd'
execute 'run local sudo tests as reqtty, no longer requiring a tty' do
  command "/opt/chef/embedded/bin/ruby -I lib test/integration/sudo/nopasswd.rb"
  cwd '/tmp/kitchen/data'
  user 'reqtty'
end
