# -*- encoding: utf-8 -*-
#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
# Author:: Dominik Richter (<dominik.richter@gmail.com>)
# Author:: Christoph Hartmann (<chris@lollyrock.com>)
#
# Copyright (C) 2014, Fletcher Nichol
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'net/ssh'
require 'net/scp'
require 'timeout'
require 'securerandom'

class Train::Transports::SSH
  # A PtyConnection instance overrides Connection#run_cmmand with a
  # stderr-related workaround.
  #
  # @author Stephan Renatus <srenatus@chef.io>
  class PtyConnection < Connection # rubocop:disable Metrics/ClassLength
    # (see Base::Connection#run_command)
    def run_command(cmd)
      stdout = stderr = ''
      exit_status = nil
      cmd.force_encoding('binary') if cmd.respond_to?(:force_encoding)
      logger.debug("[SSH/pty] #{self} (#{cmd})")

      # wrap commands if that is configured
      cmd = @cmd_wrapper.run(cmd) unless @cmd_wrapper.nil?

      # workaround missing stderr when using PTY:
      #   redirect stderr to a temp file
      #   cat and remove the temp file in a second command

      stderr = "stderr-#{SecureRandom.uuid}"
      cmd = "#{cmd} 2>#{stderr}"
      stderr_cmd = "cat #{stderr} && rm #{stderr}"
      stderr_cmd = @cmd_wrapper.run(stderr_cmd) unless @cmd_wrapper.nil?

      logger.debug("[SSH/pty] #{self} (#{cmd})")
      logger.debug("[SSH/pty] #{self} (#{stderr_cmd})")

      session.open_channel do |channel|
        channel.exec(cmd) do |_, success|
          abort 'Couldn\'t execute command on SSH.' unless success

          channel.on_data do |_, data|
            stdout += data
          end

          channel.on_request('exit-status') do |_, data|
            exit_status = data.read_long
          end

          channel.on_request('exit-signal') do |_, data|
            exit_status = data.read_long
          end

          channel.request_pty do |ch, success|
            if success
              logger.debug("[SSH/pty] #{self}: pty successfully obtained")
            else
              logger.debug("[SSH/pty] #{self}: could not obtain pty")
            end
          end
        end
      end

      session.open_channel do |channel|
        channel.exec(cmd) do |_, success|
          abort 'Couldn\'t execute stderr pty workaround command on SSH.' unless success

          channel.on_data do |_, data|
            stderr += data
          end

          channel.request_pty do |ch, success|
            if success
              logger.debug("[SSH/pty] #{self}: pty successfully obtained")
            else
              logger.debug("[SSH/pty] #{self}: could not obtain pty")
            end
          end
        end
      end

      @session.loop

      CommandResult.new(stdout, stderr, exit_status)
    rescue Net::SSH::Exception => ex
      raise Train::Transports::SSHFailed, "SSH command failed (#{ex.message})"
    end
  end
end
