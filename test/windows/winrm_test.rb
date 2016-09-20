# encoding: utf-8
# author: Christoph Hartmann
# author: Dominik Richter

require 'minitest/autorun'
require 'minitest/spec'
require 'mocha/setup'
require 'train'

describe 'windows winrm command' do
  let(:conn) {
    # get final config
    target_config = Train.target_config({
      target: ENV['train_target'],
      password: ENV['winrm_pass'],
      ssl: ENV['train_ssl'],
      self_signed: true,
    })

    # initialize train
    backend = Train.create('winrm', target_config)

    # start or reuse a connection
    conn = backend.connection
    conn
  }

  it 'verify os' do
    os = conn.os
    os[:name].must_equal 'Windows Server 2012 R2 Datacenter'
    os[:family].must_equal 'windows'
    os[:release].must_equal '6.3.9600'
    os[:arch].must_equal 'x86_64'
  end

  it 'run echo test' do
    cmd = conn.run_command('Write-Output "test"')
    cmd.stdout.must_equal "test\r\n"
    cmd.stderr.must_equal ''
  end

  it 'use powershell piping' do
    cmd = conn.run_command("New-Object -Type PSObject | Add-Member -MemberType NoteProperty -Name A -Value (Write-Output 'PropertyA') -PassThru | Add-Member -MemberType NoteProperty -Name B -Value (Write-Output 'PropertyB') -PassThru | ConvertTo-Json")
    cmd.stdout.must_equal "{\r\n    \"A\":  \"PropertyA\",\r\n    \"B\":  \"PropertyB\"\r\n}\r\n"
    cmd.stderr.must_equal ''
  end

  after do
    # close the connection
    conn.close
  end
end
