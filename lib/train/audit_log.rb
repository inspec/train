module Train
  class AuditLog
    # TODO:
    # Configurable values log location, log file size, log frequency((available options, daily, weeks, monthly))

    # Default values for audit log options are set in the options.rb
    def self.create(options = {})
      logger = Logger.new(options[:audit_log_location], options[:audit_log_frequency], options[:audit_log_size])
      logger.level = options[:level] || Logger::INFO
      logger.progname = options[:audi_log_app_name]
      logger.datetime_format = "%Y-%m-%d %H:%M:%S"
      logger.formatter = proc do |severity, datetime, progname, msg|
        {
          timestamp: datetime.to_s,
          app: progname,
        }.merge(msg).compact.to_json + $/
      end
      logger
    end
  end
end