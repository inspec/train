# encoding: utf-8
# author: Dominik Richter
# author: Christoph Hartmann

require 'helper'
require 'train/transports/mock'
require 'train/extras'
require 'base64'

describe 'linux command' do
  let(:cls) { Train::Extras::LinuxCommand }
  let(:cmd) { rand.to_s }
  let(:backend) {
    backend = Train::Transports::Mock.new.connection
    backend.mock_os({ family: 'linux' })
    backend
  }

  describe 'sudo wrapping' do
    it 'wraps commands in sudo' do
      lc = cls.new(backend, { sudo: true })
      lc.run(cmd).must_equal "sudo #{cmd}"
    end

    it 'doesnt wrap commands in sudo if user == root' do
      lc = cls.new(backend, { sudo: true, user: 'root' })
      lc.run(cmd).must_equal cmd
    end

    it 'wraps commands in sudo with all options' do
      opts = rand.to_s
      lc = cls.new(backend, { sudo: true, sudo_options: opts })
      lc.run(cmd).must_equal "sudo #{opts} #{cmd}"
    end

    it 'runs commands in sudo with password' do
      pw = rand.to_s
      lc = cls.new(backend, { sudo: true, sudo_password: pw })
      bpw = Base64.strict_encode64(pw + "\n")
      lc.run(cmd).must_equal "echo #{bpw} | base64 --decode | sudo -S #{cmd}"
    end

    it 'wraps commands in sudo_command instead of sudo' do
      sudo_command = rand.to_s
      lc = cls.new(backend, { sudo: true, sudo_command: sudo_command })
      lc.run(cmd).must_equal "#{sudo_command} #{cmd}"
    end

    it 'wraps commands in sudo_command with all options' do
      opts = rand.to_s
      sudo_command = rand.to_s
      lc = cls.new(backend, { sudo: true, sudo_command: sudo_command, sudo_options: opts })
      lc.run(cmd).must_equal "#{sudo_command} #{opts} #{cmd}"
    end

    it 'runs commands in sudo_command with password' do
      pw = rand.to_s
      sudo_command = rand.to_s
      lc = cls.new(backend, { sudo: true, sudo_command: sudo_command, sudo_password: pw })
      bpw = Base64.strict_encode64(pw + "\n")
      lc.run(cmd).must_equal "echo #{bpw} | base64 --decode | #{sudo_command} -S #{cmd}"
    end
  end

  describe 'shell wrapping' do
    it 'wraps commands in a default shell with login' do
      lc = cls.new(backend, { shell: true, shell_options: '--login' })
      bcmd = Base64.strict_encode64(cmd)
      lc.run(cmd).must_equal "echo #{bcmd} | base64 --decode | $SHELL --login"
    end

    it 'wraps sudo commands in a default shell with login' do
      lc = cls.new(backend, { sudo: true, shell: true, shell_options: '--login' })
      bcmd = Base64.strict_encode64("sudo #{cmd}")
      lc.run(cmd).must_equal "echo #{bcmd} | base64 --decode | $SHELL --login"
    end

    it 'wraps sudo commands and sudo passwords in a default shell with login' do
      pw = rand.to_s
      lc = cls.new(backend, { sudo: true, sudo_password: pw, shell: true, shell_options: '--login' })
      bpw = Base64.strict_encode64(pw + "\n")
      bcmd = Base64.strict_encode64("echo #{bpw} | base64 --decode | sudo -S #{cmd}")
      lc.run(cmd).must_equal "echo #{bcmd} | base64 --decode | $SHELL --login"
      p bcmd
    end

    it 'wraps commands in a default shell when shell is true' do
      lc = cls.new(backend, { shell: true })
      bcmd = Base64.strict_encode64(cmd)
      lc.run(cmd).must_equal "echo #{bcmd} | base64 --decode | $SHELL"
    end

    it 'doesnt wrap commands in a shell when shell is false' do
      lc = cls.new(backend, { shell: false })
      lc.run(cmd).must_equal cmd
    end

    it 'wraps commands in a `shell` instead of default shell' do
      lc = cls.new(backend, { shell: true, shell_command: '/bin/bash' })
      bcmd = Base64.strict_encode64(cmd)
      lc.run(cmd).must_equal "echo #{bcmd} | base64 --decode | /bin/bash"
    end

    it 'wraps commands in a default shell with login' do
      lc = cls.new(backend, { shell: true, shell_command: '/bin/bash', shell_options: '--login' })
      bcmd = Base64.strict_encode64(cmd)
      lc.run(cmd).must_equal "echo #{bcmd} | base64 --decode | /bin/bash --login"
    end
  end
end
