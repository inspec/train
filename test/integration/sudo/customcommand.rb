# encoding: utf-8
# author: Jeremy Miller

require_relative 'run_as'

describe 'run custom sudo command' do
  it 'is running as non-root without sudo' do
    run_as('whoami').stdout.wont_match(/root/i)
  end

  it 'is running nopasswd custom sudo command' do
    run_as('whoami', { sudo: true, sudo_command: 'allyourbase' })
      .stdout.must_match(/root/i)
  end
end
