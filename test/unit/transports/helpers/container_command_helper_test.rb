require "helper"
require "train/transports/helpers/container_command_helper"

describe Train::Transports::Helpers::ContainerCommandHelper do
  class DummyContainerInvoker
    include Train::Transports::Helpers::ContainerCommandHelper

    def initialize(windows)
      @windows = windows
    end

    def invocation_for(cmd, cmd_wrapper: nil)
      send(:build_container_invocation, cmd, cmd_wrapper: cmd_wrapper)
    end

    private

    def sniff_for_windows?
      @windows
    end
  end

  let(:wrapper) do
    stub(run: "wrapped-command")
  end

  it "uses sh invocation when target is not windows" do
    invoker = DummyContainerInvoker.new(false)

    invocation = invoker.invocation_for("echo hello")

    assert_equal(["/bin/sh", "-c", "echo hello"], invocation)
  end

  it "uses cmd invocation when target is windows" do
    invoker = DummyContainerInvoker.new(true)

    invocation = invoker.invocation_for("echo hello")

    assert_equal(["cmd.exe", "/s", "/c", "echo hello"], invocation)
  end

  it "applies a command wrapper before invocation selection" do
    invoker = DummyContainerInvoker.new(false)

    invocation = invoker.invocation_for("echo hello", cmd_wrapper: wrapper)

    assert_equal(["/bin/sh", "-c", "wrapped-command"], invocation)
  end
end