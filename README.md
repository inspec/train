# Train - Transport Interface

* **Project State: Active**
* **Issues Response SLA: 3 business days**
* **Pull Request Response SLA: 3 business days**

For more information on project states and SLAs, see [this documentation](https://github.com/chef/chef-oss-practices/blob/master/repo-management/repo-states.md).

[![Build status](https://badge.buildkite.com/ee9d6f49d995b23e943955b12d5aaadf4314d12b7cc99b03be.svg?branch=master)](https://buildkite.com/chef-oss/inspec-train-master-verify)
[![Gem Version](https://badge.fury.io/rb/train.svg)](https://badge.fury.io/rb/train)
[![Coverage Status](https://coveralls.io/repos/github/inspec/train/badge.svg?branch=master)](https://coveralls.io/github/inspec/train?branch=master)

**Umbrella Project**: [Chef Foundation](https://github.com/chef/chef-oss-practices/blob/master/projects/chef-foundation.md)

**Project State**: [Active](https://github.com/chef/chef-oss-practices/blob/master/repo-management/repo-states.md#active)

**Issues [Response Time Maximum](https://github.com/chef/chef-oss-practices/blob/master/repo-management/repo-states.md)**: 14 days

**Pull Request [Response Time Maximum](https://github.com/chef/chef-oss-practices/blob/master/repo-management/repo-states.md)**: 14 days

Train lets you talk to your local or remote operating systems and APIs with a unified interface.

It allows you to:

* execute commands via `run_command`
* interact with files via `file`
* identify the target operating system via `os`
* authenticate to API-based services and treat them like a platform

Train supports:

* Local execution
* SSH
* WinRM
* Docker
* Mock (for testing and debugging)
* AWS as an API
* Azure as an API
* VMware via PowerCLI
* Habitat

# Examples

## Setup

**Local**

```ruby
require 'train'
train = Train.create('local')
```

**SSH**

```ruby
require 'train'
train = Train.create('ssh',
  host: '1.2.3.4', port: 22, user: 'root', key_files: '/vagrant')
```

If you don't specify the `key_files` and `password` options, SSH agent authentication will be attempted. For example:

```ruby
require 'train'
train = Train.create('ssh', host: '1.2.3.4', port: 22, user: 'root')
```

SSH transport has an `ssh_config_file` option to set the SSH config file path. This is set by default to `true` to read the values from the default SSH config file path. For example, `~/.ssh/config`, `/etc/ssh_config`, `/etc/ssh/ssh_config`. Precedence is given to the options set through the arguments.

**WinRM**

```ruby
require 'train'
train = Train.create('winrm',
  host: '1.2.3.4', user: 'Administrator', password: '...', ssl: true, self_signed: true)
```

**Docker**

```ruby
require 'train'
train = Train.create('docker', host: 'container_id...')
```
You can use `user` option to connect with privileged user on non root user images.

```ruby
require 'train'
train = Train.create('docker', host: 'container_id...', user: 'root')
```

For Docker Desktop for Windows, you must enable the "Expose daemon on tcp://localhost:2375 without TLS" setting. To change the URL that train uses to connect to Docker, use the `docker_url` option:

```ruby
require 'train'
train = Train.create('docker', host: 'container_id...', docker_url: 'tcp://localhost:1234')
```

Windows Docker containers require PowerShell, which is assumed to be installed as `powershell.exe`. If it is installed as `pwsh`, use the `--shell-command` option to specify `pwsh` as the shell.

**Podman**

```ruby
require 'train'
train = Train.create('podman', host: 'container_id...')
```

```ruby
require 'train'
train = Train.create('podman', host: 'container_id...', podman_url: 'tcp://localhost:1234')
```

To connect to the Podman container Podman API endpoint URL needs to set. It cans et through the `podman_url` option else it will check for the CONTAINER_HOST environment variable. If both is not defined then it will try to connect to the default URL that is `unix:///run/user/UID/podman/podman.sock` for non-root user and `unix:///run/podman/podman.sock` for root user. Precedence is given to the options set through the arguments.

**AWS**

To use AWS API authentication, setup an AWS client profile to store the Access Key ID and Secret Access Key.

```ruby
require 'train'
train = Train.create('aws', region: 'us-east-2', profile: 'my-profile')
```

You may also use the standard AWS CLI environment variables, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` and `AWS_REGION`.

```ruby
require 'train'
train = Train.create('aws')
```

**VMware**

```ruby
require 'train'
Train.create('vmware', viserver: '10.0.0.10', user: 'demouser', password: 'securepassword')
```

You may also use environment variables by setting `VISERVER`, `VISERVER__USERNAME`, and `VISERVER_PASSWORD`

```ruby
require 'train'
Train.create('vmware')
```

## Configuration

To get a list of available options for a plugin:

```ruby
puts Train.options('ssh')
```
This will provide all configuration options:

```ruby
{
  :host     => { :required => true},
  :port     => { :default  => 22, :required => true},
  :user     => { :default  => "root", :required => true},
  :keys     => { :default  => nil},
  :password => { :default  => nil},
  ...
```

## Usage

```ruby
# start or reuse a connection
conn = train.connection

# run a command on Linux/Unix/Mac
puts conn.run_command('whoami').stdout

# get OS info
puts conn.os[:family]
puts conn.os[:release]

# access files
puts conn.file('/proc/version').content

# access specific API client functionality
ec2_client = train.connection.aws_client(Aws::EC2::Client)
puts ec2_client.describe_instances

# close the connection
conn.close
```

# Testing

We perform `unit`, `integration` and `windows` tests.

* `unit` tests ensure the intended behaviour of the implementation
* `integration` tests run against VMs and docker containers
* `windows` tests that run on appveyor for windows integration tests

## Mac/Linux

```
bundle exec ruby -W -Ilib:test/unit test/unit/extras/stat_test.rb
```

## Windows

```
# run windows tests
bundle exec rake test:windows

# run single tests
bundle exec ruby -I .\test\windows\ .\test\windows\local_test.rb
```


# Kudos and Contributors

Train is heavily based on the work of:

* [test-kitchen](https://github.com/test-kitchen/test-kitchen)

    by [Fletcher Nichol](mailto:fnichol@nichol.ca)
    and [a great community of contributors](https://github.com/test-kitchen/test-kitchen/graphs/contributors)

* [ohai](https://github.com/chef/ohai)

    by Adam Jacob, Chef Software Inc.
    and [a great community of contributors](https://github.com/chef/ohai/graphs/contributors)


We also want to thank [halo](https://github.com/halo) who did a great contribution by handing over the `train` gem name.

## Contributing

1. Fork it
1. Create your feature branch (git checkout -b my-new-feature)
1. Commit your changes (git commit -am 'Add some feature')
1. Push to the branch (git push origin my-new-feature)
1. Create new Pull Request

## License

| **Author:**          | Dominik Richter (<drichter@chef.io>)

| **Author:**          | Christoph Hartmann (<chartmann@chef.io>)

| **Copyright:**       | Copyright (c) 2015-2019 Chef Software Inc.

| **Copyright:**       | Copyright (c) 2015 Vulcano Security GmbH.

| **License:**         | Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
