# Train Audit Logs

## About Audit Logs

The Train Audit Log is intended to log the activities happening through the Train Connection on the target system. **The Audit log feature is in preview and may change at any time.**

Generally, Train Connections perform three types of operations - File, Command, and API operations.

Audit Logging works by intercepting these operations and writing details about the method call to the audit log before the call is made. Specifically, it captures the invocations that are executed on the target system through `run_command` and captures file paths that are accessed through the Train connection.

## Limitations

As this is a feature preview to determine what sort of functionality is desired by the user base, no attempt at completeness was made in this release. Currently, the Train Audit Log has the following limitations:

* Strong support for command invocations but no ability to control level of detail of output
* Limited ability to see file operations. A file access may be seen, but what specific operation may be unknown.
* Not all File operations are perfomed using the top-level connection methods; some file operations are implemented in the transport plugins, and are not captured consistently 
* No support for API calls at this time. No API-based transports will show traffic in the audit log.

## Log Format

Depending on the type of event in the log, the log will contain a line containing a JSON object in one of several variants.

### Command Event

In case of command execution, it logs information like timestamp, type (currently it is cmd), command (the invocation that ran on the target system), user (system user who executed the command), and hostname (hostname of the system, if it is a remote target).

```json
{"timestamp":"2023-11-06 11:21:32 -0500","app":"train","type":"cmd","command":"whoami"}
```

### File Event

In the case of file operation it currently only logs the file path that has been accessed and some additional data like timestamp, type (file), user (system user who executed the command), and hostname (hostname of the system if it is a remote target).

```json
{"timestamp":"2023-11-06 11:23:59 -0500","app":"train","type":"file","path":"/tmp"}
```

### API Event

Reserved for future use.

## Log Options

Audit logs are `disabled` by default. To enable the audit log and configure it use the following audit log options while creating the Train object.

Log size and Frequency come from Ruby's Logger implementation; see that for details.

`enable_audit_log`: Type boolean. Default is false.

`audit_log_location`: Type String, path to stem filename to create such as "~/chef/logs/my-app-audit.log" Default is nil.

`audit_log_size`: Type numeric. Maximum size of the file in bytes before it gets rotated to another file. Default is 2097152.

`audit_log_frequency`: Type string. Frequency with which to rotate the audit log. Default is daily (Valid values: daily, weekly, monthly).

## Driving Train from IRB

Note: this is an example for developers; Train is a support library and has no direct UI. Most people use Audit Logging through an application that embeds it such as Chef InSpec.


```ruby
  require 'train'
  t = Train.create('local', enable_audit_log: true, audit_log_location: "my.log")
  c = t.connection
  c.run_command("whoami")
  c.file("<path-to-file>").content
```
