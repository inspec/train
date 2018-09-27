# Example Train Plugin - train-local-rot13

This plugin is provided as a teaching example for building a Train plugin.  Train plugins allow you to connect to remote systems or APIs, so that other tools such as InSpec or Chef Workstation can talk over the connection.

train-local-rot13's functionality is simple: it acts as a local transport (targeting the local machine), but it applies the [rot13](https://en.wikipedia.org/wiki/ROT13) trivial cypher transformation on the contents of each file it reads, and on the stdout of every command it executes.

Please note that ROT13 is an incredibly weak cypher, and can be broken by most elementary school students.  Do not use this plugin for security purposes.

## Relationship between InSpec and Train

Train itself has no CLI, nor a sophisticated test harness.  InSpec does have such facilities, so installing Train plugins will require an InSpec installation.  You do not need to use or understand InSpec.

Train plugins may be developed without an InSpec installation.

## To Install this as a User

You will need InSpec v2.3 or later.

If you just want to use this (not learn how to write a plugin), you can so by simply running:

```
$ inspec plugin install train-local-rot13
```

You can then run:

```
$ inspec detect -t local-rot13://
== Platform Details

Name:      local-rot13
Families:  unix, os, windows, os
Release:   0.1.0
Arch:      example

$ inspec shell -t local-rot13:// -c 'command("echo hello")'
uryyb
```

## Features of This Example Kit

This example plugin is a full-fledged plugin example, with everything a real-world, industrial grade plugin would have, including:

* an implementation of a Train plugin, using the Train Plugin V1 API, including
  * a Transport
  * a Connection
  * Platform configuration
* documentation (you are reading it now)
* tests, at the unit and functional level
* a .gemspec, for packaging and publishing it as a gem
* a Gemfile, for managing its dependencies
* a Rakefile, for running development tasks
* Rubocop linting support for using the base Train project rubocop.yml (See Rakefile)

You are encouraged to use this plugin as a starting point for real plugins.

## Development of a Plugin

[Plugin Development](https://github.com/inspec/train/blob/master/docs/dev/plugins.md) is documented on the `train` project on GitHub.  Additionally, this example
plugin has extensive comments explaining what is happening, and why.

### A Tour of the Plugin

One nice circuit of the plugin might be:
 * look at the gemspec, to see what the plugin thinks it does
 * look at the functional tests, to see the plugin proving it does what it says
 * look at the unit tests, to see how the plugin claims it is internally structured
 * look at the Rakefile, to see how to interact with the project
 * look at lib/train-local-rot13.rb, the entry point which InSpec will always load if the plugin is installed
 * look at lib/train-local-rot13/transport.rb, the plugin "backbone"
 * look at lib/train-local-rot13/connection.rb, the plugin implementation
 * look at lib/train-local-rot13/platform.rb, OS platform support declaration
