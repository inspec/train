# encoding: utf-8
#
# Copyright 2017, Noah Kantrowitz


require_relative 'helper'

require 'json'
require 'logger'

require 'mixlib/shellout'

require 'train'

IMAGES = %w{
  centos:5.11
  centos:6.8
  centos:7.2.1511
  debian:6.0.10
  debian:7.11
  debian:8.5
  fedora:20
  fedora:21
  fedora:22
  fedora:23
  fedora:24
  oraclelinux:5.11
  oraclelinux:6.8
  oraclelinux:7.2
  ubuntu:10.04
  ubuntu:12.04
  ubuntu:14.04
  ubuntu:16.04
  ubuntu:16.10
}

# IMAGES = %w{  centos:5.11 }

POD_TEMPLATE = <<-POD
apiVersion: v1
kind: Pod
metadata:
  name: %{name}
spec:
  containers:
  - name: default
    image: %{image}
    command: ["/bin/sh", "-c", "trap 'exit 0' TERM; sleep 2147483647 & wait"]
POD

def kubectl(*cmd)
  Mixlib::ShellOut.new('kubectl', *cmd).tap(&:run_command)
end

def kubectl!(*cmd)
  kubectl(*cmd).tap(&:error!)
end

# Create a pod and yield the name.
#
# @param image [String] Docker image to run.
# @return [String] Name of the created pod.
def create_pod(image)
  # Use a random name to avoid overlaps.
  pod_name = "traintest-#{image.gsub(/:/, '-')}-#{rand(2**32)}"
  pod_yaml = POD_TEMPLATE % {name: pod_name, image: image}
  kubectl!('create', '-f', '-', input: pod_yaml)
  # Wait for the pod to be ready.
  status = nil
  start_time = Time.now
  while status != 'Running'
    if Time.now - start_time > 20
      # More than 20 seconds, start giving user feedback. 20 second threshold
      # was 100% pulled from my ass based on how long it takes to launch
      # on my local minikube, may need changing for reality.
      puts("--> Waiting for pod #{pod_name} to be running, currently #{status}")
    end
    sleep(1)
    status_cmd = kubectl('get', 'pod', pod_name, '--output=json')
    unless status_cmd.error? || status_cmd.stdout.empty?
      status = JSON.parse(status_cmd.stdout)['status']['phase']
    end
  end
  # This could be handled by serializing things in to the container command but
  # this is just easier and keeps compat with Docker tests more simply.
  bootstrap_script = File.expand_path('../bootstrap.sh', __FILE__)
  kubectl!('exec', '--stdin', pod_name, '--', '/bin/sh', '-', input: IO.read(bootstrap_script))
  # Return the pod name for use by other code.
  pod_name
end

# Clean up a pod.
#
# @param pod_name [String] Name of the pod to delete.
# @return [void]
def delete_pod(pod_name)
  # Make sure we try to clean up after ourselves.
  kubectl('delete', 'pod', pod_name, '--now')
end

# Train defaults to debug logging.
logger = Logger.new(STDOUT)
logger.level = Logger::WARN

# Set up a home for our pods and pod locks. Use threads to speed things up
# since we are creating a lot of pods at once.
puts "--> Starting #{IMAGES.length} pods"
PODS = IMAGES.map do |image|
  Thread.new do
    name = create_pod(image)
    conn = Train.create('kubernetes', pod: name, logger: logger).connection
    {image => {name: name, conn: conn}}
  end
end.each_with_object({}) do |th, memo|
  memo.update(th.value)
end
# PODS = IMAGES.each_with_object({}) do |image, memo|
#   name = create_pod(image)
#   conn = Train.create('kubernetes', pod: name, logger: logger).connection
#   memo[image] = {name: name, conn: conn}
# end

# Make sure we clean up all the pods at the end.
Minitest.after_run do
  # This ignore the locks in case of funky errors, we're cleaning up no matter what.
  PODS.each do |_, pod|
    delete_pod(pod[:name])
  end
end

# Generate all the Minitest specs that we need.
describe 'Kubernetes functional tests' do
  IMAGES.each do |image|
    describe image do
      # In the Docker tests this is a local variable but try make things more
      # controlled, use a let variable here.
      let(:get_backend) do
        # To match the calling convention used by the docker tests this must
        # return a callable.
        lambda do
          PODS[image][:conn]
        end
      end

      # Tests are passed on the command line by the Rake task.
      ARGV.each do |test|
        # Create the actual tests.
        instance_eval(IO.read(test), test)
      end
    end
  end
end
