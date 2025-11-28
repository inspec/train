module Train::Platforms::Detect::Helpers
  module Windows
    def detect_windows
      check_cmd || check_powershell
    end

    def check_cmd
      # try to detect windows, use cmd.exe to also support Microsoft OpenSSH
      res = @backend.run_command("cmd.exe /c ver")

      return false if (res.exit_status != 0) || res.stdout.empty?

      # if the ver contains `Windows`, we know its a Windows system
      version = res.stdout.strip
      return false unless version.downcase =~ /windows/

      @platform[:family] = "windows"

      # try to extract release from eg. `Microsoft Windows [Version 6.3.9600]`
      release = /\[(?<name>.*)\]/.match(version)
      if release[:name]
        # release is 6.3.9600 now
        @platform[:release] = release[:name].downcase.gsub("version", "").strip
        # fallback, if we are not able to extract the name from wmic later
        @platform[:name] = "Windows #{@platform[:release]}"
      end

      # Prefer retrieving the OS details via `wmic` if available on the system to retain existing behavior.
      # If `wmic` is not available, fall back to using cmd-only commands as an alternative method.
      wmic_available? ? read_wmic : read_cmd_os
      true
    end

    def check_powershell
      command = @backend.run_command(
        "Get-WmiObject Win32_OperatingSystem | Select Caption,Version | ConvertTo-Json"
      )
      # some targets (e.g. Cisco) may return 0 and print an error to stdout
      return false if (command.exit_status != 0) || command.stdout.downcase !~ /window/

      begin
        payload = JSON.parse(command.stdout)
        @platform[:family] = "windows"
        @platform[:release] = payload["Version"]
        @platform[:name] = payload["Caption"]

        # Prefer retrieving the OS details via `wmic` if available on the system to retain existing behavior.
        # If `wmic` is not available, fall back to using CIM as an alternative method.
        wmic_available? ? read_wmic : read_cim_os
        true
      rescue
        false
      end
    end

    def local_windows?
      @backend.class.to_s == "Train::Transports::Local::Connection" &&
        ruby_host_os(/mswin|mingw|windows/)
    end

    # reads os name and version from wmic
    # @see https://msdn.microsoft.com/en-us/library/bb742610.aspx#EEAA
    # Thanks to Matt Wrock (https://github.com/mwrock) for this hint
    def read_wmic
      res = @backend.run_command("wmic os get * /format:list")
      if res.exit_status == 0
        sys_info = {}
        res.stdout.lines.each do |line|
          m = /^\s*([^=]*?)\s*=\s*(.*?)\s*$/.match(line)
          sys_info[m[1].to_sym] = m[2] unless m.nil? || m[1].nil?
        end

        @platform[:release] = sys_info[:Version]
        # additional info on windows
        @platform[:build] = sys_info[:BuildNumber]
        @platform[:name] = sys_info[:Caption]
        @platform[:name] = @platform[:name].gsub("Microsoft", "").strip unless @platform[:name].empty?
        @platform[:arch] = read_wmic_cpu
      end
    end

    # `OSArchitecture` from `read_wmic` does not match a normal standard
    # For example, `x86_64` shows as `64-bit`
    def read_wmic_cpu
      res = @backend.run_command("wmic cpu get architecture /format:list")
      if res.exit_status == 0
        sys_info = {}
        res.stdout.lines.each do |line|
          m = /^\s*([^=]*?)\s*=\s*(.*?)\s*$/.match(line)
          sys_info[m[1].to_sym] = m[2] unless m.nil? || m[1].nil?
        end
      end

      # This converts `wmic os get architecture` output to a normal standard
      # https://msdn.microsoft.com/en-us/library/aa394373(VS.85).aspx
      arch_map = {
        0 => "i386",
        1 => "mips",
        2 => "alpha",
        3 => "powerpc",
        5 => "arm",
        6 => "ia64",
        9 => "x86_64",
      }

      # The value of `wmic cpu get architecture` is always a number between 0-9
      arch_number = sys_info[:Architecture].to_i
      arch_map[arch_number]
    end

    # This method scans the target os for a unique uuid to use
    def windows_uuid
      uuid = windows_uuid_from_chef
      uuid = windows_uuid_from_machine_file if uuid.nil?
      uuid = windows_uuid_from_wmic_or_cim if uuid.nil?
      uuid = windows_uuid_from_registry if uuid.nil?
      raise Train::TransportError, "Cannot find a UUID for your node." if uuid.nil?

      uuid
    end

    def windows_uuid_from_machine_file
      %W{
        #{ENV["SYSTEMDRIVE"]}\\chef\\chef_guid
        #{ENV["HOMEDRIVE"]}#{ENV["HOMEPATH"]}\\.chef\\chef_guid
      }.each do |path|
        file = @backend.file(path)
        return file.content.chomp if file.exist? && file.size != 0
      end
      nil
    end

    def windows_uuid_from_chef
      file = @backend.file("#{ENV["SYSTEMDRIVE"]}\\chef\\cache\\data_collector_metadata.json")
      return if !file.exist? || file.size == 0

      json = JSON.parse(file.content)
      json["node_uuid"]
    end

    def windows_uuid_from_wmic_or_cim
      # Retrieve the Windows UUID using `wmic` if it is available and not marked as deprecated, maintaining compatibility with older systems.
      # If `wmic` is unavailable or deprecated, use the `Get-CimInstance` command, which is the modern and recommended approach by Microsoft.
      wmic_available? ? windows_uuid_from_wmic : windows_uuid_from_cim
    end

    def windows_uuid_from_wmic
      # Switched from `wmic csproduct get UUID` to `wmic csproduct get UUID /value`
      # to make the parsing of the UUID more reliable and consistent.
      #
      # When using the original `wmic csproduct get UUID` command, the output includes
      # a header line and spacing that can vary depending on the system, making it harder
      # to reliably extract the UUID. In some cases, splitting by line and taking the last
      # element returns an empty string, even when exit_status is 0.
      #
      # Example:
      #
      # (byebug) result = @backend.run_command("wmic csproduct get UUID")
      # #<struct Train::Extras::CommandResult stdout="UUID                                  \r\r\nEC20EBD7-8E03-06A8-645F-2D22E5A3BA4B  \r\r\n\r\r\n", stderr="", exit_status=0>
      # (byebug) result.stdout
      # "UUID                                  \r\r\nEC20EBD7-8E03-06A8-645F-2D22E5A3BA4B  \r\r\n\r\r\n"
      # (byebug) result.exit_status
      # 0
      # (byebug) result.stdout.split("\r\n")[-1].strip
      # ""
      #
      # In contrast, `wmic csproduct get UUID /value` returns a consistent `UUID=<value>` format,
      # which is more suitable for regex matching.
      #
      # Example:
      #
      # byebug) result = @backend.run_command("wmic csproduct get UUID /value")
      # #<struct Train::Extras::CommandResult stdout="\r\r\n\r\r\nUUID=EC20EBD7-8E03-06A8-645F-2D22E5A3BA4B\r\r\n\r\r\n\r\r\n\r\r\n", stderr="", exit_status=0>
      # (byebug) result.stdout
      # "\r\r\n\r\r\nUUID=EC20EBD7-8E03-06A8-645F-2D22E5A3BA4B\r\r\n\r\r\n\r\r\n\r\r\n"
      # (byebug) result.stdout&.match(/UUID=([A-F0-9\-]+)/i)&.captures&.first
      # "EC20EBD7-8E03-06A8-645F-2D22E5A3BA4B"
      #
      # This change improves parsing reliability and handles edge cases where the previous
      # approach would return `nil` or raise errors on empty output lines.

      result = @backend.run_command("wmic csproduct get UUID /value")
      return unless result.exit_status == 0

      result.stdout&.match(/UUID=([A-F0-9\-]+)/i)&.captures&.first
    end

    def windows_uuid_from_registry
      cmd = '(Get-ItemProperty "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography" -Name "MachineGuid")."MachineGuid"'
      result = @backend.run_command(cmd)
      return unless result.exit_status == 0

      result.stdout.chomp
    end

    # Checks if `wmic` is available and not deprecated
    def wmic_available?
      # Return memoized value if already checked
      return @wmic_available unless @wmic_available.nil?

      # Runs the `wmic /?`` command, which provides help information for the WMIC (Windows Management Instrumentation Command-line) tool.
      # It displays a list of available global switches and aliases, as well as details about their usage.
      # The output also includes information about deprecated status for the 'wmic' tool.
      result = @backend.run_command("wmic /?")

      # Check if command ran successfully and output does not contain 'wmic is deprecated'
      @wmic_available = result.exit_status == 0 && !(result.stdout.downcase.include?("wmic is deprecated"))
    end

    def read_cim_os
      cmd = 'powershell -Command "Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber | ConvertTo-Json"'
      res = @backend.run_command(cmd)
      return unless res.exit_status == 0

      begin
        sys_info = JSON.parse(res.stdout)
        @platform[:release] = sys_info["Version"]
        @platform[:build] = sys_info["BuildNumber"]
        @platform[:name] = sys_info["Caption"]
        @platform[:name] = @platform[:name].gsub("Microsoft", "").strip unless @platform[:name].empty?
        @platform[:arch] = read_cim_cpu
      rescue
        nil
      end
    end

    def read_cim_cpu
      cmd = 'powershell -Command "(Get-CimInstance Win32_Processor).Architecture"'
      res = @backend.run_command(cmd)
      return unless res.exit_status == 0

      arch_map = {
        0 => "i386",
        1 => "mips",
        2 => "alpha",
        3 => "powerpc",
        5 => "arm",
        6 => "ia64",
        9 => "x86_64",
      }

      arch_map[res.stdout.strip.to_i]
    end

    # Fallback method for reading OS info using cmd-only commands when wmic is not available
    def read_cmd_os
      # Try to get architecture from PROCESSOR_ARCHITECTURE environment variable
      # This covers the same architectures as wmic CPU detection but uses environment variables
      # which are available on all Windows versions since NT
      arch_res = @backend.run_command("echo %PROCESSOR_ARCHITECTURE%")
      if arch_res.exit_status == 0
        arch_string = arch_res.stdout.strip.downcase
        @platform[:arch] = case arch_string
                          when "x86"
                            "i386"
                          when "amd64", "x64"
                            "x86_64"
                          when "ppc", "powerpc"
                            "powerpc"
                          else
                            # For any unknown architecture, preserve the original value
                            # This handles: arm64, ia64, arm, mips, alpha, and future architectures
                            arch_string
                           end
      end
      # If PROCESSOR_ARCHITECTURE fails, architecture remains unset (consistent with other methods)

      # Try to get more detailed OS info from systeminfo command as fallback
      # This is slower than wmic but works without PowerShell
      # Only override the basic info from check_cmd if systeminfo provides better data
      sysinfo_res = @backend.run_command("systeminfo")
      if sysinfo_res.exit_status == 0
        sysinfo_res.stdout.lines.each do |line|
          line = line.strip
          if line =~ /^OS Name:\s*(.+)$/i
            os_name = $1.strip
            # Only override if we get a more detailed name than the basic "Windows X.X.X" from check_cmd
            detailed_name = os_name.gsub("Microsoft", "").strip
            @platform[:name] = detailed_name unless detailed_name.empty?
          elsif line =~ /^OS Version:\s*(.+)$/i
            version_info = $1.strip
            # Extract version number from format like "10.0.19044 N/A Build 19044"
            if version_info =~ /^(\d+\.\d+\.\d+)/
              # Only override release if systeminfo provides the same or more detailed version
              systeminfo_release = $1
              @platform[:release] = systeminfo_release if systeminfo_release
            end
            # Extract build number (this is additional info not available from check_cmd)
            if version_info =~ /Build (\d+)/
              @platform[:build] = $1
            end
          end
        end
      end
      # If systeminfo fails, we keep the basic info from check_cmd method
    end

    def windows_uuid_from_cim
      cmd = 'powershell -Command "(Get-CimInstance -Class Win32_ComputerSystemProduct).UUID"'
      res = @backend.run_command(cmd)
      return unless res.exit_status == 0

      res.stdout.strip
    end

  end
end
