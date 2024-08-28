# Train Plugins

## Introducing Plugins

Train plugins are a way to add new transports and platform detection to Train.

If you are familiar with InSpec plugins, be forewarned; the two plugin systems are not similar.

### Why Plugins?

#### Benefits of plugins

Plugins address two main needs that the Chef InSpec Engineering team (which maintains Train) encountered in 2017-2018:

* Passionate contributor parties can develop and release new Train transports at their own pace, without gating by Chef engineers.
* Reduction of dependency bloat within Train.  For example, since only the AWS transport needs the aws-sdk, we can move the gem dependency into the plugin gem, and out of train itself.

#### Future of existing Transports

The Chef InSpec Engineering team currently (October 2018) plans to migrate most existing Train transports into plugins.  For example, AWS, Azure, and GCP are all excellent candidates for migration to plugin status.  The team commits to keeping SSH, WinRM, and Local transports in Train core.  All other transports may be migrated.

In the near-term, InSpec will carry a gemspec dependency on the migrated plugins.  This will continue a smooth experience for users relying on (for example) Azure.

## Managing Plugins

### Installing and Managing Train Plugins as an InSpec User

InSpec has a command-line plugin management interface, which is used for managing both InSpec plugins and Train plugins.  For example, to install `train-aws`, simply run:

```bash
$ inspec plugin install train-aws
```

The management facility can install, update, and remove plugins, including their dependencies.

### Installing Train Plugins outside of InSpec

If you need a train plugin installed, and `inspec plugin` is not available to you, you can install a train plugin like any other gem.  Just be sure to use the `gem` binary that comes with the application you wish to extend.  For example, to add a Train Plugin to a ChefDK installation, use:

```bash
$ chef exec gem install train-something
```

### Finding Train plugins

Train plugins can be found by running:

```bash
$ inspec plugin search train-
```

If you are not an InSpec user, you may also perform a RubyGems search:

```bash
$ gem search train-
```

## Developing Train Plugins for the Train Plugin API v1

Train plugins are gems.  Their names must start with 'train-'.

You can use the example plugin at [the Train github project](https://github.com/inspec/train/tree/master/examples/plugins/train-local-rot13) as a starting point.

### The Entry Point

As with any Gem library, you should create a file with the name of your plugin, which loads the remaining files you need.  Some plugins place them in 1 file, but it is cleaner to place them in 4: a version file, then transport, connection and platform files.

### The Transport File

In this file, you should define a class that inherits from `Train.plugin(1)`.  The class returned will be `Train::Plugins::Transport` or a descendant.  This superclass provides DSL methods, abstract methods, instance variables, and accessors for you to configure your plugin.

Feedback about providing a clearer Plugin API for a future Plugin V2 API is welcome.

#### `name` DSL method

Required. Use the `name` call to register your plugin.  Pass a String, which should have the 'train-' portion removed.

#### `option` DSL method

The option method is used to register new information into your transport options hash. This hash contains all the information your transport will need for its connection and runtime support. These options calls are a good place to pull in defaults or information from environment variables.

#### @options Instance Variable

This variable includes any options you passed in from the DSL method when defining a transport. It will also merge in any options passed from the URL definition for your transport (schema, host, etc).

#### `connection` abstract method

Required to be implemented. Called with a single arg which is usually ignored.  You must return an instance of a class that is a descendant of `Train::Plugins::Transports::BaseConnection`.  Typically you will call the constructor with the `@options`.

### Connection File

The your Connection class must inherit from `Train::Plugins::Transports::BaseConnection`.  Abstract methods it should implement include:

#### initialize

Not required but is a good place to set option defaults for options that were passed with the transport URL. Example:

```Ruby
def initialize(options)
  # Override for cli region from url host
  # aws://region/my-profile
  options[:region] = options[:host] if options.key?(:host)
  super(options)
end
```

#### file_via_connection

If your transport is OS based and has the option to read a file you can set this method. It is expected to return a `Train::File::Remote::*` class here to be used upstream in InSpec. Currently the file resource is restricted to Unix and Windows platforms. Caching is enabled by default for this method.

#### run_command_via_connection

If your transport is OS based and has the option to run a command you can set this method. It is expected to return a `CommandResult` class here to be used upstream in InSpec. Currently the command resource is restricted to Unix and Windows platforms. Caching is enabled by default for this method.  
You can optionally receive an options hash as well as the command string. This is intended for options that apply only to the current instance of running a command. For example, applying a timeout to this command execution.

#### API Access Methods

When working with API's it's often helpful to create methods to return client information or API objects. These are then accessed upstream in InSpec. Here is an example of a API method you may have:

```Ruby
def aws_client(klass)
  return klass.new unless cache_enabled?(:api_call)
  @cache[:api_call][klass.to_s.to_sym] ||= klass.new
end
```

This will return a class and cache the client object accordingly if caching is enabled. You can call this from a inspec resource by calling `inspec.backend.aws_client(AWS::TEST::CLASS)`.

#### platform

`platform` is called when InSpec is trying to detect the platform (OS family, etc).  We recommend that you implement platform in a separate Module, and include it.

### Platform Detection

Platform detection is used if you do not specify a platform method for your transport. Currently it is only used for OS (Unix, Windows) platforms. The detection system will run a series of commands on your target to try and determine what platform it is. This information can be found here [OS Specifications](https://github.com/inspec/train/blob/master/lib/train/platforms/detect/specifications/os.rb).

When using an API or a fixed platform for your transport it's suggested you skip the detection process and specify a direct platform. Here is an example:

```Ruby
def platform
 Train::Platforms.name('Aws').in_family('cloud')
 force_platform!('Aws',
   release: '1.2',
 )
end
```
Example config for transport that supports `unix` and `windows` OS,

```Ruby
def platform
  Train::Platforms.name("local-rot13").in_family("unix")
  Train::Platforms.name("local-rot13").in_family("windows")
  force_platform!("local-rot13", release: TrainPlugins::LocalRot13::VERSION)
end
```
