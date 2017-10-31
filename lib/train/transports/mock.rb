# encoding: utf-8

require 'train/plugins'
require 'digest'

module Train::Transports
  class Mock < Train.plugin(1)
    name 'mock'

    def initialize(conf = nil)
      @conf = conf || {}
      trace_calls if @conf[:trace]
    end

    def connection
      @connection ||= Connection.new(@conf)
    end

    def to_s
      'Mock Transport'
    end

    private

    def trace_calls
      interface_methods = {
        'Train::Transports::Mock' =>
          Train::Transports::Mock.instance_methods(false),
        'Train::Transports::Mock::Connection' =>
          Connection.instance_methods(false),
        'Train::Transports::Mock::Connection::File' =>
          Connection::FileCommon.instance_methods(false),
        'Train::Transports::Mock::Connection::OS' =>
          Train::Platform.instance_methods(false),
      }

      # rubocop:disable Metrics/ParameterLists
      # rubocop:disable Lint/Eval
      set_trace_func proc { |event, _file, _line, id, binding, classname|
        unless classname.to_s.start_with?('Train::Transports::Mock') and
               event == 'call' and
               interface_methods[classname.to_s].include?(id)
          next
        end
        # kindly borrowed from the wonderful simple-tracer by matugm
        arg_names = eval(
          'method(__method__).parameters.map { |arg| arg[1].to_s }',
          binding)
        args = eval("#{arg_names}.map { |arg| eval(arg) }", binding).join(', ')
        prefix = '-' * (classname.to_s.count(':') - 2) + '> '
        puts("#{prefix}#{id} #{args}")
      }
      # rubocop:enable all
    end
  end
end

class Train::Transports::Mock
  class Connection < BaseConnection
    attr_accessor :files, :commands
    attr_reader :os

    def initialize(conf = nil)
      Train::Platforms::Specifications::OS.load_specifications
      super(conf)
      @os = mock_os({})
      @commands = {}
    end

    def uri
      'mock://'
    end

    def mock_os(value)
      value[:name] = 'unknown' unless value[:name]
      platform = Train::Platforms.name(value[:name])
      platform.family_hierarchy = mock_os_hierarchy(platform).flatten
      platform.platform[:family] = platform.family_hierarchy[0]
      platform.add_platform_methods
      @os = platform
    end

    def mock_os_hierarchy(plat)
      plat.families.each_with_object([]) do |(k, _v), memo|
        memo << k.name
        memo << mock_os_hierarchy(k) unless k.families.empty?
      end
    end

    def mock_command(cmd, stdout = nil, stderr = nil, exit_status = 0)
      @commands[cmd] = Command.new(stdout || '', stderr || '', exit_status)
    end

    def command_not_found(cmd)
      if @options[:verbose]
        STDERR.puts('Command not mocked:')
        STDERR.puts('    '+cmd.to_s.split("\n").join("\n    "))
        STDERR.puts('    SHA: ' + Digest::SHA256.hexdigest(cmd.to_s))
      end
      # return a non-zero exit code
      mock_command(cmd, nil, nil, 1)
    end

    def run_command(cmd)
      @commands[cmd] ||
        @commands[Digest::SHA256.hexdigest cmd.to_s] ||
        command_not_found(cmd)
    end

    def file_not_found(path)
      STDERR.puts('File not mocked: '+path.to_s) if @options[:verbose]
      File.new(self, path)
    end

    def file(path)
      @files[path] ||= file_not_found(path)
    end

    def to_s
      'Mock Connection'
    end
  end
end

class Train::Transports::Mock::Connection
  Command = Struct.new(:stdout, :stderr, :exit_status)
end

class Train::Transports::Mock::Connection
  class File < Train::File
    def self.from_json(json)
      res = new(json['backend'],
                json['path'],
                json['follow_symlink'])
      res.type = json['type']
      Train::File::DATA_FIELDS.each do |f|
        m = (f.tr('?', '') + '=').to_sym
        res.method(m).call(json[f])
      end
      res
    end

    Train::File::DATA_FIELDS.each do |m|
      attr_accessor m.tr('?', '').to_sym
      next unless m.include?('?')

      define_method m.to_sym do
        method(m.tr('?', '').to_sym).call
      end
    end
    attr_accessor :type

    def initialize(backend, path, follow_symlink = true)
      super(backend, path, follow_symlink)
      @type = :unknown
      @exist = false
    end

    def mounted
      @mounted ||=
        @backend.run_command("mount | grep -- ' on #{@path}'")
    end
  end
end
