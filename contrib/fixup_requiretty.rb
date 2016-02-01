# encoding: utf-8
# author: Stephan Renatus
#
# chef-apply script to fix sudoers configuration
#
# This script can be used to setup a user's sudoers configuration to allow for
# using non-interactive sessions. It's main use case is fixing the default
# configuration on RHEL and SEL distributions.
#
# The user name has to be provided in the env varibale "TRAIN_SUDO_USER".
# If any configuration for the user is present (user is in /etc/sudoers or
# /etc/sudoers.d/user exists), this script will do nothing
# (unless you set TRAIN_SUDO_VERY_MUCH=yes)

# FIXME
user = ENV['TRAIN_SUDO_USER'] || 'todo-some-clever-default-maybe-current-user'
sudoer = "/etc/sudoers.d/#{user}"

log "Warning: a sudoers configuration for user #{user} already exists, "\
    'doing nothing (override with TRAIN_SUDO_VERY_MUCH=yes)' do
  only_if "test -f #{sudoer} || grep #{user} /etc/sudoers"
end

file sudoer do
  content "#{user} ALL=(root) NOPASSWD:ALL\n"\
          "Defaults:#{user} !requiretty\n"
  mode 0600
  action ENV['TRAIN_SUDO_VERY_MUCH'] == 'yes' ? :create : :create_if_missing

  # Do not add something here if the user is mentioned explicitly in /etc/sudoers
  not_if "grep #{user} /etc/sudoers"
end

# /!\ broken files in /etc/sudoers.d/ will break sudo for ALL USERS /!\
execute "revert: delete the file if it's broken" do
  command "rm #{sudoer}"
  not_if "visudo -c -f #{sudoer}" # file is ok
end
