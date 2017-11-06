# encoding: utf-8
#
# Copyright 2017, Noah Kantrowitz

require 'mixlib/shellout'

require 'train/errors'

module Train::Transports
  class SSHFailed < Train::TransportError; end

  class Kubernetes < Train.plugin(1)
    name 'kubernetes'

    include_options Train::Extras::CommandWrapper
    option :pod, required: true
    option :container, default: nil
    option :kubectl_path, default: 'kubectl'

    def connection(state = {})
      opts = merge_options(options, state || {})
      validate_options(opts)
      opts[:logger] ||= logger
      unless @connection && @connection_opts == opts
        @connection ||= Connection.new(opts)
        @connection_opts = opts.dup
      end
      @connection
    end

    class Connection < BaseConnection
      def os
        @os ||= OS.new(self)
      end

      def file(path)
        @files[path] ||= Train::File::Remote::Linux.new(self, path)
      end

      def run_command(cmd)
        kubectl_cmd = [options[:kubectl_path], 'exec']
        kubectl_cmd.concat(['--container', options[:container]]) if options[:container]
        kubectl_cmd.concat([options[:pod], '--', '/bin/sh', '-c', cmd])

        so = Mixlib::ShellOut.new(kubectl_cmd, logger: logger)
        so.run_command
        if so.error?
          # Trim the "command terminated with exit code N" line from the end
          # of the stderr content.
          so.stderr.gsub!(/command terminated with exit code #{so.exitstatus}\n\Z/, '')
        end
        CommandResult.new(so.stdout, so.stderr, so.exitstatus)
      end

      def uri
        if options[:container]
          "kubernetes://#{options[:pod]}/#{options[:container]}"
        else
          "kubernetes://#{options[:pod]}"
        end
      end

      class OS < OSCommon
        def initialize(backend)
          # hardcoded to unix/linux for now, until other operating systems
          # are supported
          super(backend, { family: 'unix' })
        end
      end
    end
  end
end
