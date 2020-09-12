#!/usr/bin/env rake
require "bundler"
require "bundler/gem_helper"
require "rake/testtask"
require "chefstyle"
require "rubocop/rake_task"

Bundler::GemHelper.install_tasks name: "train"

RuboCop::RakeTask.new(:lint) do |task|
  task.options << "--display-cop-names"
end

# run tests
task default: %i{test}

Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/unit/**/*_test.rb"
  t.warning = false
  t.verbose = true
  t.ruby_opts = ["--dev"] if defined?(JRUBY_VERSION)
end

namespace :test do
  task :docker do
    path = File.join(__dir__, "test", "integration")
    sh("sh", "-c", "cd #{path} && ruby -I ../../lib docker_test.rb tests/*")
  end

  task :windows do
    Dir.glob("test/windows/*_test.rb").all? do |file|
      sh(Gem.ruby, "-w", '-I .\test\windows', file)
    end || raise("Failures")
  end

  task :vm do
    concurrency = ENV["CONCURRENCY"] || 4
    path = File.join(__dir__, "test", "integration")
    sh("sh", "-c", "cd #{path} && kitchen test -c #{concurrency}")
  end

  # Target required:
  #   rake "test:ssh[user@server]"
  #   sh -c cd /home/foobarbam/src/gems/train/test/integration \
  #     && target=user@server ruby -I ../../lib test_ssh.rb tests/*
  #   ...
  # Turn debug logging back on:
  #   debug=1 rake "test:ssh[user@server]"
  # Use a different ssh key:
  #   key_files=/home/foobarbam/.ssh/id_rsa2 rake "test:ssh[user@server]"
  # Run with a specific test:
  #   test=path_block_device_test.rb rake "test:ssh[user@server]"
  task :ssh, [:target] do |t, args|
    path = File.join(__dir__, "test", "integration")
    key_files = ENV["key_files"] || File.join(ENV["HOME"], ".ssh", "id_rsa")

    sh_cmd = "cd #{path} && target=#{args[:target]} key_files=#{key_files}"

    sh_cmd += " debug=#{ENV["debug"]}" if ENV["debug"]
    sh_cmd += " ruby -I ../../lib test_ssh.rb tests/"
    sh_cmd += ENV["test"] || "*"

    sh("sh", "-c", sh_cmd)
  end
end
