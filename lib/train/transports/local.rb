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

    class Connection < BaseConnection # rubocop:disable Metrics/ClassLength
      require 'json'
      require 'base64'

      def initialize(options)
        super(options)
        @cmd_wrapper = nil
        @cmd_wrapper = CommandWrapper.load(self, options)
      end

      def login_command
        nil # none, open your shell
      end

      def uri
        'local://'
      end

      def local?
        true
      end

      private

      def run_powershell_using_named_pipe(script)
        pipe = nil
        # Try to acquire pipe for 10 seconds with 0.1 second intervals.
        # Removing this can result in instability due to the pipe being
        # temporarily unavailable.
        100.times do
          begin
            pipe = open('//localhost/pipe/InSpec', 'r+')
            break
          rescue
            sleep 0.1
          end
        end
        fail 'Could not open pipe `//localhost/pipe/InSpec`' if pipe.nil?
        # Prevent progress stream from leaking to stderr
        script = "$ProgressPreference='SilentlyContinue';" + script
        encoded_script = Base64.strict_encode64(script)
        pipe.puts(encoded_script)
        pipe.flush
        result = JSON.parse(Base64.decode64(pipe.readline))
        pipe.close
        result
      end

      def start_named_pipe_server # rubocop:disable Metrics/MethodLength
        require 'win32/process'

        script = <<-EOF
          $ProgressPreference = 'SilentlyContinue'
          $ErrorActionPreference = 'Stop'

          Function Execute-UserCommand($userInput) {
            $command = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($userInput))

            $scriptBlock = $ExecutionContext.InvokeCommand.NewScriptBlock($command)
            try {
              $stdout = & $scriptBlock | Out-String
              $result = @{ 'stdout' = $stdout ; 'stderr' = ''; 'exitstatus' = 0 }
            } catch {
              $stderr = $_ | Out-String
              $result = @{ 'stdout' = ''; 'stderr' = $_; 'exitstatus' = 1 }
            }
            return $result | ConvertTo-JSON
          }

          Function Start-PipeServer {
            while($true) {
              # Attempt to acquire a pipe for 10 seconds, trying every 100 milliseconds
              for($i=1; $i -le 100; $i++) {
                try {
                  $pipeServer = New-Object System.IO.Pipes.NamedPipeServerStream('InSpec', [System.IO.Pipes.PipeDirection]::InOut)
                  break
                } catch {
                  Start-Sleep -m 100
                  if($i -eq 100) { throw }
                }
              }
              $pipeReader = New-Object System.IO.StreamReader($pipeServer)
              $pipeWriter = New-Object System.IO.StreamWriter($pipeServer)

              $pipeServer.WaitForConnection()
              $pipeWriter.AutoFlush = $true

              $clientConnected = $true
              while($clientConnected) {
                $input = $pipeReader.ReadLine()

                if($input -eq $null) {
                  $clientConnected = $false
                  $pipeServer.Dispose()
                } else {
                  $result = Execute-UserCommand($input)
                  $encodedResult = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($result))
                  $pipeWriter.WriteLine($encodedResult)
                }
              }
            }
          }
          Start-PipeServer
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
