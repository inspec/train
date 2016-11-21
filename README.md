# Train - Transport Interface

[![Build Status](https://travis-ci.org/chef/train.svg?branch=master)](https://travis-ci.org/chef/train)
[![Build Status Master](https://ci.appveyor.com/api/projects/status/github/chef/train?branch=master&svg=true&passingText=master%20-%20Ok&pendingText=master%20-%20Pending&failingText=master%20-%20Failing)](https://ci.appveyor.com/project/Chef/train/branch/master)
[![Gem Version](https://badge.fury.io/rb/train.svg)](https://badge.fury.io/rb/train)

Train lets you talk to your local or remote operating systems with a unified interface.

It allows you to:

* execute commands via `run_command`
* interact with files via `file`
* identify the target operating system via `os`

Train supports:

* Local execution
* SSH
* WinRM
* Docker
* Mock (for testing and debugging)

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

    by [Fletcher Nichol](fnichol@nichol.ca)
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

| **Copyright:**       | Copyright (c) 2015 Chef Software Inc.

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
