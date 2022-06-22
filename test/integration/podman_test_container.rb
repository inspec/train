require "train"
require_relative "helper"


(container_id = ENV["CONTAINER"]) ||
  raise("You must provide a container ID via CONTAINER env"
)

(podman_url = ENV["CONTAINER_HOST"])

tests = ARGV
puts ["Running tests:", tests].flatten.join("\n- ")
puts ""

backends = {}
backends[:podman] = proc { |*args|
  opt = Train.target_config({ host: container_id, podman_url: podman_url })
  Train.create("podman", opt).connection(args[0])
}

backends.each do |type, get_backend|
  tests.each do |test|
    instance_eval(File.read(test), test, 1)
  end
end
