# encoding: utf-8
# author: Dominik Richter
# author: Christoph Hartmann
# author: Stephan Renatus

require_relative 'run_as'

describe 'run_command' do
  it 'is running as non-root without sudo' do
    run_as('whoami').stdout.wont_match /root/i
  end

  it 'is throwing an error trying to use sudo' do
    err = ->{ run_as('whoami', { sudo: true }) }.must_raise Train::UserError
    err.message.must_match /Sudo failed: Sudo requires a TTY. Please see the README/i
  end
end
