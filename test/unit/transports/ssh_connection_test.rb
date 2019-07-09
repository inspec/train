require "helper"
require "train/transports/ssh"
require "train/transports/ssh_connection"

# Mocha limitations don't let us mock a function
# such that it can receive a block, so here's a minimal
# class that simulates Net::SSH::Connection::Channel to the
# extent required by Transports::SSH::Connection
class MockChannel
  def exec(cmd)
    @cmd = cmd
    yield("ignored", true)
  end

  def data_handler
    @handler
  end

  def on_data(&block)
    @handler = block
  end

  def mock_inbound_data(data)
    # trigger the 'on-data' event off of the channel.
    @handler.call("ignored", data)
  end

  def on_extended_data; end

  def on_request(any); end
end

describe "ssh connection" do
  let(:cls) do
    plat = Train::Platforms.name("mock").in_family("linux")
    plat.add_platform_methods
    Train::Platforms::Detect.stubs(:scan).returns(plat)
    Train::Transports::SSH::Connection
  end
  let(:conf) do
    {
      host: rand.to_s,
      password: rand.to_s,
      transport_options: {},
    }
  end

  describe "#run_command_via_connection through BaseConnection::run_command" do
    let(:ssh) { cls.new(conf) }
    # A bit more mocking than I'd like to see, but there's no sane way around
    # it if we want to test output handling behavior.
    let(:inbound_data) { "testdata" }
    let(:channel_mock) { MockChannel.new }

    let(:session_mock) do
      session_mock = mock
      session_mock.stubs(:closed?).returns false
      session_mock.stubs(:open_channel).yields(channel_mock)
      # Simulate the way that Net::SSH::Session processes request(s) on invoking #loop.
      session_mock.stubs(:loop).with do
        channel_mock.mock_inbound_data(inbound_data)
      end
      session_mock
    end

    it "invokes the provided block when a block is provided and data is received" do
      ssh.stubs(:session).returns(session_mock)
      called = false
      # run_command b/c run_command_via_connection is private.
      ssh.run_command("test") do |data|
        called = true
        data.must_equal inbound_data
      end
      called.must_equal true

    end
  end
end
