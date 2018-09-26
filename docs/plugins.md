# Train Plugins

## Introducing Plugins

Train plugins are a way to add new transports and platform detection to Train.

If you are familiar with InSpec plugins, be forewarned; the two plugin systems are not similar.

### Why Plugins?

#### Benefits of plugins

Plugins address two main needs that the Chef InSpec Engineering team encountered in 2017-2018.

* Passionate contributors parties can develop and release new Train transports at their own pace, without gating by Chef engineers.
* Reduction of dependency bloat within Train.  For example, since only the AWS transport need the aws-sdk, we can move the gem dependency into the plugin gem, and out of train itself.

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

If you are not an InSpec user, you may also perform a rubygems search.

## Developing Train Plugins for the Train Plugin API v1

Train plugins are gems.  Their names always start with 'train-'.

You can use the example plugin at [the Train github project](https://github.com/inspec/train/tree/master/examples/train-local-rot13) as a starting point.

### The Entry Point

As with any Gem library, you should create a file with the name of your plugin, which loads the remaining files you need.  Some plugins place them in 1 file, but it is cleaner to place them in 4: a version file, then transport, connection and platform files.

### The Transport File

In this file, you should define a class that inherits from `Train.plugin(1)`.  The class returned will be `Train::Plugins::Transport` or a descendant.  This superclass provides DSL methods for you to configure your plugin.

#### name

Required. Use the `name` call to register your plugin.  Pass a String, which should have the 'train-' portion removed.

#### option



### The Connection

### Platform Detection

