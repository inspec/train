# encoding: utf-8
# author: Dominik Richter
# author: Christoph Hartmann

require_relative 'run_as'

describe 'run_command' do
  it 'is running as non-root without sudo' do
    run_as('whoami').stdout.wont_match /root/i
  end

  it 'is not running sudo without password' do
    err = ->{Train.create('local', { sudo: true }).connection}.must_raise Train::UserError
    err.message.must_match /Sudo requires a password/
  end

  it 'is running passwd sudo' do
    run_as('whoami', { sudo: true, sudo_password: 'password' })
      .stdout.must_match /root/i
  end
end
