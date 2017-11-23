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
      require 'json'
      require 'base64'
      require 'securerandom'

      def initialize(options)
        super(options)
        @cmd_wrapper = nil
        @cmd_wrapper = CommandWrapper.load(self, options)
        @pipe = acquire_named_pipe if @platform.windows?
      end

      def run_command(cmd)
        if defined?(@pipe)
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

      def local?
        true
      end

      def file(path)
        @files[path] ||= \
          if os.windows?
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

      private

      def acquire_named_pipe
        pipe_name = "inspec_#{SecureRandom.hex}"
        pipe_location = "//localhost/pipe/#{pipe_name}"
        start_named_pipe_server(pipe_name) unless File.exist?(pipe_location)

        # Try to acquire pipe for 10 seconds with 0.1 second intervals.
        # This allows time for PowerShell to start the pipe
        pipe = nil
        100.times do
          begin
            pipe = open(pipe_location, 'r+')
            break
          rescue
            sleep 0.1
          end
        end
        fail "Could not open named pipe #{pipe_location}" if pipe.nil?

        pipe
      end

      def run_powershell_using_named_pipe(script)
        script = "$ProgressPreference='SilentlyContinue';" + script
        encoded_script = Base64.strict_encode64(script)
        @pipe.puts(encoded_script)
        @pipe.flush
        JSON.parse(Base64.decode64(@pipe.readline))
      end

      def start_named_pipe_server(pipe_name)
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
