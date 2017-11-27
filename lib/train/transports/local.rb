# encoding: utf-8
#
# author: Dominik Richter
# author: Christoph Hartmann

require 'train/plugins'
require 'mixlib/shellout'

module Train::Transports
  class Local < Train.plugin(1)
    name 'local'

    include_options Train::Extras::CommandWrapper

    def connection(_ = nil)
      @connection ||= Connection.new(@options)
    end

    class Connection < BaseConnection
      def initialize(options)
        super(options)
        @cmd_wrapper = nil
        @cmd_wrapper = CommandWrapper.load(self, options)
        @platform = platform
      end

      def run_command(cmd)
        if defined?(@platform) && @platform.windows?
          @windows_runner ||= WindowsRunner.new
          @windows_runner.run_command(cmd)
        else
          cmd = @cmd_wrapper.run(cmd) unless @cmd_wrapper.nil?
          res = Mixlib::ShellOut.new(cmd)
          res.run_command
          CommandResult.new(res.stdout, res.stderr, res.exitstatus)
        end
      rescue Errno::ENOENT => _
        CommandResult.new('', '', 1)
      end

      def local?
        true
      end

      def file(path)
        @files[path] ||= if os.windows?
                           Train::File::Local::Windows.new(self, path)
                         else
                           Train::File::Local::Unix.new(self, path)
                         end
      end

      def login_command
        nil # none, open your shell
      end

      def uri
        'local://'
      end

      class WindowsRunner
        require 'json'
        require 'base64'
        require 'securerandom'

        def initialize
          @pipe = acquire_pipe
        end

        def run_command(cmd)
          res = @pipe ? run_via_pipe(cmd) : run_via_shellout(cmd)
          Local::CommandResult.new(res.stdout, res.stderr, res.exitstatus)
        rescue Errno::ENOENT => _
          CommandResult.new('', '', 1)
        end

        private

        def acquire_pipe
          pipe_name = Dir.entries('//./pipe/').find { |f| f =~ /inspec_/ }

          return create_pipe("inspec_#{SecureRandom.hex}") if pipe_name.nil?

          begin
            pipe = open("//./pipe/#{pipe_name}", 'r+')
          rescue
            # Pipes are closed when a Train connection ends. When running
            # multiple independent scans (e.g. Unit tests) the pipe will be
            # unavailable because the previous process is closing it.
            # This creates a new pipe in that case
            pipe = create_pipe("inspec_#{SecureRandom.hex}")
          end

          return false if pipe.nil?

          pipe
        end

        def create_pipe(pipe_name)
          start_pipe_server(pipe_name)

          pipe = nil

          # PowerShell needs time to create pipe.
          100.times do
            begin
              pipe = open("//./pipe/#{pipe_name}", 'r+')
              break
            rescue
              sleep 0.1
            end
          end

          return false if pipe.nil?

          pipe
        end

        def run_via_shellout(script)
          # Prevent progress stream from leaking into stderr
          script = "$ProgressPreference='SilentlyContinue';" + script

          # Encode script so PowerShell can use it
          script = script.encode('UTF-16LE', 'UTF-8')
          base64_script = Base64.strict_encode64(script)

          cmd = "powershell -NoProfile -EncodedCommand #{base64_script}"

          res = Mixlib::ShellOut.new(cmd)
          res.run_command
        end

        def run_via_pipe(script)
          script = "$ProgressPreference='SilentlyContinue';" + script
          encoded_script = Base64.strict_encode64(script)
          @pipe.puts(encoded_script)
          @pipe.flush
          OpenStruct.new(JSON.parse(Base64.decode64(@pipe.readline)))
        end

        def start_pipe_server(pipe_name)
          require 'win32/process'

          script = <<-EOF
            $ErrorActionPreference = 'Stop'

            $pipeServer = New-Object System.IO.Pipes.NamedPipeServerStream('#{pipe_name}')
            $pipeReader = New-Object System.IO.StreamReader($pipeServer)
            $pipeWriter = New-Object System.IO.StreamWriter($pipeServer)

            $pipeServer.WaitForConnection()

            # Create loop to receive and process user commands/scripts
            $clientConnected = $true
            while($clientConnected) {
              $input = $pipeReader.ReadLine()
              $command = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($input))

              # Execute user command/script and convert result to JSON
              $scriptBlock = $ExecutionContext.InvokeCommand.NewScriptBlock($command)
              try {
                $stdout = & $scriptBlock | Out-String
                $result = @{ 'stdout' = $stdout ; 'stderr' = ''; 'exitstatus' = 0 }
              } catch {
                $stderr = $_ | Out-String
                $result = @{ 'stdout' = ''; 'stderr' = $_; 'exitstatus' = 1 }
              }
              $resultJSON = $result | ConvertTo-JSON

              # Encode JSON in Base64 and write to pipe
              $encodedResult = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($resultJSON))
              $pipeWriter.WriteLine($encodedResult)
              $pipeWriter.Flush()
            }
          EOF

          utf8_script = script.encode('UTF-16LE', 'UTF-8')
          base64_script = Base64.strict_encode64(utf8_script)
          cmd = "powershell -NoProfile -ExecutionPolicy bypass -NonInteractive -EncodedCommand #{base64_script}"

          server_pid = Process.create(command_line: cmd).process_id

          # Ensure process is killed when the Train process exits
          at_exit { Process.kill('KILL', server_pid) }
        end
      end

      def run_command_via_connection(cmd)
        if defined?(@platform) && @platform.windows?
          start_named_pipe_server unless File.exist?('//localhost/pipe/InSpec')
          res = run_powershell_using_named_pipe(cmd)
          CommandResult.new(res['stdout'], res['stderr'], res['exitstatus'])
        else
          cmd = @cmd_wrapper.run(cmd) unless @cmd_wrapper.nil?
          res = Mixlib::ShellOut.new(cmd)
          res.run_command
          CommandResult.new(res.stdout, res.stderr, res.exitstatus)
        end
      rescue Errno::ENOENT => _
        CommandResult.new('', '', 1)
      end

      def file_via_connection(path)
        if os.windows?
          Train::File::Local::Windows.new(self, path)
        else
          Train::File::Local::Unix.new(self, path)
        end
      end
    end
  end
end
