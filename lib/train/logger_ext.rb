
# Part of Audit Log.
# The default logger implementation injects a comment as the first line of the
# log file, which makes it an invalid JSON file. No way to disable that other than monkey-patching.

class Logger::LogDevice
  def add_log_header(file); end
end