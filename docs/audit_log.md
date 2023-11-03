# Train Audit Logs

Train audit is integrated to log the activities happening through train on target system.
Currently, it is scoped to log the commands that are executed on the target system through `run_command` and logs file path that is accessed through train connection.
Logs are stored in the JSON format at a given log location. In case of command execution, it logs information like timestamp, type (currently it is cmd), command (the command that ran on the target system), user (system user who executed the command), and hostname (hostname of the system, if it is a remote target).
In the case of file operation it currently only logs the file path that has been accessed and some additional data like timestamp, type (file), user (system user who executed the command), and hostname (hostname of the system if it is a remote target).

** Note: Currently audit logging system is not mature enough to log all the activities with all types of train plugins.

## Enable audit log

Audit logs are `disabled` by default. To enable the audit log and configure it use the following audit log options while creating the Train object.

`disable_audit_log`: Type boolean. Default is true.

`audit_log_location`: Type String. Default is nil.

`audit_log_size`: Type numeric. Default is 2097152.

`audit_log_frequency`: Type string, Default is daily (Valid values: daily, weekly, monthly).

* Example:

```ruby
  require 'train'
  t = Train.create('local', enable_audit_log: true)
  c = t.connection
  c.run_command("whoami")
  c.file("<path-to-file>").content
```
