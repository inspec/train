# encoding: utf-8

module Train::Platforms::Detect
  module Uname
    def uname_s
      return @uname_s unless @uname_s.nil?
      @uname_s = @backend.run_command('uname -s').stdout
    end

    def uname_r
      return @uname_r unless @uname_r.nil?
      @uname_r = begin
                     res = @backend.run_command('uname -r').stdout
                     res.strip! unless res.nil?
                     res
                   end
    end

    def uname_m
      return @uname_m unless @uname_m.nil?
      @uname_m = @backend.run_command('uname -m').stdout.chomp
    end
  end
end
