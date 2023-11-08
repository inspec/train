# Train Audit Log

**The Train audit log feature is in preview to determine what features the user base might want and may change at any time.**

The Train audit log logs the activities happening through the Train connection on the target system.

Train connections perform three types of operations:

- file
- command
- API operations

Train intercepts these operations and writes details about the method call to the audit log before the call is made.
Specifically, it captures the invocations that are executed on the target system through `run_command` and captures file paths that are accessed through the Train connection.

## Limitations

The Train audit log has the following limitations:

- Strong support for command invocations, but no ability to control level of output detail.
- Limited ability to see file operations. A file access may be seen, but what specific operation may be unknown.
- Not all file operations are performed using the top-level connection methods; some file operations are implemented in the transport plugins and are not captured consistently.
- No support for API calls at this time. No API-based transports will show traffic in the audit log.

## Log format

The audit log records event data in a JSON object. The data returned varies based on the event type.

### Command event

The audit log returns the following command execution data:

- timestamp
- type (`cmd`)
- command (the invocation run on the target system)
- user (system user who executes the command)
- hostname (hostname of the system if it is a remote target)

The following example shows data returned from a command event.

```json
{"timestamp":"2023-11-06 11:21:32 -0500","app":"train","type":"cmd","command":"whoami"}
```

### File event

The audit log returns the following file event data:

- file path that has been accessed
- timestamp
- type (`file`)
- user (system user who executed the command)
- hostname (hostname of the system if it is a remote target)

The following example shows data returned from a file event.

```json
{"timestamp":"2023-11-06 11:23:59 -0500","app":"train","type":"file","path":"/tmp"}
```

### API event

Reserved for future use.

## Log Options

Audit Logs are disabled by default. To enable and configure the audit log, use the following audit log options while creating the Train object:

- Log size and frequency come from Ruby's Logger implementation. See Ruby's Logger documentation for details.
- `enable_audit_log`: Type Boolean. Default is `false`.
- `audit_log_location`: Type String. Path to audit log file. For example, `"~/chef/logs/my-app-audit.log"`. Default is nil.
- `audit_log_size`: Type Numeric. Maximum file size in bytes before it gets rotated to another file. Log rotation is disabled by default. Defaults to `1048576` (1MB)
- `audit_log_frequency`: Frequency of rotation (`daily`, `weekly`, or `monthly`). Default value is `0`, which disables log file rotation.

## Driving Train from IRB

Note: this is an example for developers; Train is a support library and has no direct UI. Most people use audit log through an application that embeds Train, such as Chef InSpec.

```ruby
  require 'train'
  t = Train.create('local', enable_audit_log: true, audit_log_location: "my.log")
  c = t.connection
  c.run_command("whoami")
  c.file("<path-to-file>").content
```
