# encoding: utf-8
# author: Dominik Richter
# author: Christoph Hartmann
#
# This is heavily based on:
#
#   OHAI https://github.com/chef/ohai
#   by Adam Jacob, Chef Software Inc
#
module Train::Extras
  module Uname
    def uname_s
      @uname_s ||= backend.run_command('uname -s').stdout
    end

    def uname_r
      @uname_r ||= begin
                     res = backend.run_command('uname -r').stdout
                     res.strip! unless res.nil?
                     res
                   end
    end

    def uname_m
      @uname_m ||= backend.run_command('uname -m').stdout.chomp
    end
  end
end
