# encoding: utf-8
#
# author: Dominik Richter
# author: Christoph Hartmann

require 'train/plugins'
require 'mixlib/shellout'

require 'win32/process'
require 'base64'

module Train::Transports
  class Local < Train.plugin(1)
    name 'local'

    include_options Train::Extras::CommandWrapper

    def connection(_ = nil)
      @connection ||= Connection.new(@options)
    end

    class Connection < BaseConnection
      require 'train/transports/local_file'
      require 'train/transports/local_os'

      def initialize(options)
        super(options)
        @server = start_server()
        @cmd_wrapper = nil
        @cmd_wrapper = CommandWrapper.load(self, options)
      end

      def close
        Net::HTTP.post(URI("http://localhost:8888"), "exit")
      end

      def run_command(cmd)
        resp = Net::HTTP.post(URI("http://localhost:8888/"), cmd)
        if resp.code == "200"
          CommandResult.new(resp.body, '', 0)
        else
          CommandResult.new('', resp.body, 1)
        end
      rescue Errno::ENOENT => _
        CommandResult.new('', '', 1)
      end

      def os
        @os ||= OS.new(self)
      end

      def file(path)
        @files[path] ||= File.new(self, path)
      end

      def login_command
        nil # none, open your shell
      end

      def uri
        'local://'
      end

      def start_server
        server_script = <<EOF
$ProgressPreference='SilentlyContinue'
Function Start-Server {
    Process {
        $ErrorActionPreference = "Stop"

        $listener = New-Object System.Net.HttpListener
        $listener.Prefixes.Add("http://localhost:8888/")
        try {
            $listener.Start()
            while ($true) {
                $statusCode = 200
                $context = $listener.GetContext()
                $request = $context.Request

                $command = ""
                $size = $request.ContentLength64 + 1
                $buffer = New-Object byte[] $size
                do {
                    $count = $request.InputStream.Read($buffer, 0, $size)
                    $command += $request.ContentEncoding.GetString($buffer, 0, $count)
                } until($count -lt $size)
                $request.InputStream.Close()

                if ($command -eq "exit") {
                    return
                }

                try {
                    $script = $ExecutionContext.InvokeCommand.NewScriptBlock($command)
                    $commandOutput = & $script
                } catch {
                    $commandOutput = $_
                    $statusCode = 500
                }

                $commandOutput = $commandOutput | Out-String

                if (!$commandOutput) {
                    $commandOutput = [string]::Empty
                }
                Write-Verbose $commandOutput
                $response = $context.Response
                $response.StatusCode = $statusCode
                $buffer = [System.Text.Encoding]::UTF8.GetBytes($commandOutput)

                $response.ContentLength64 = $buffer.Length
                $output = $response.OutputStream
                $output.Write($buffer,0,$buffer.Length)
                $output.Close()
            }
        } finally {
            $listener.Stop()
        }
    }
}
Start-Server
EOF
        encoded = Base64.strict_encode64(server_script.encode('UTF-16LE', 'UTF-8'))
        cmd = "powershell -noprofile -executionpolicy bypass -noninteractive -encodedcommand #{encoded}"
        Process.create(command_line: cmd)
      end

    end
  end
end
