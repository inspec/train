module Train
  module Transports
    module Helpers
      module ContainerCommandHelper
        private

        def build_container_invocation(cmd, cmd_wrapper: nil)
          cmd = cmd_wrapper.run(cmd) unless cmd_wrapper.nil?

          # Cannot use os.windows? here because it calls run_command_via_connection,
          # causing infinite recursion during initial platform detection.
          sniff_for_windows? ? cmd_run_command(cmd) : sh_run_command(cmd)
        end

        def sh_run_command(cmd)
          ["/bin/sh", "-c", cmd]
        end

        def cmd_run_command(cmd)
          ["cmd.exe", "/s", "/c", cmd]
        end
      end
    end
  end
end