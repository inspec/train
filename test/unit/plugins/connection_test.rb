require "helper"

describe "v1 Connection Plugin" do
  describe "empty v1 connection plugin" do
    let(:cls) { Train::Plugins::Transport::BaseConnection }
    let(:connection) { cls.new({}) }

    it "provides a close method" do
      connection.close # wont raise
    end

    it "raises NotImplementedError exception for run_command" do
      _ { connection.run_command("") }.must_raise NotImplementedError
    end

    it "raises NotImplementedError exception for run_command with options hash (arity of 2)" do
      _ { connection.run_command("", {}) }.must_raise NotImplementedError
    end

    it "raises an exception for run_command_via_connection" do
      _ { connection.send(:run_command_via_connection, "") }.must_raise NotImplementedError
    end

    it "raises an exception for os method" do
      _ { connection.os }.must_raise NotImplementedError
    end

    it "raises an exception for file method" do
      _ { connection.file("") }.must_raise NotImplementedError
    end

    it "raises an exception for file_via_connection method" do
      _ { connection.send(:file_via_connection, "") }.must_raise NotImplementedError
    end

    it "raises an exception for login command method" do
      _ { connection.login_command }.must_raise NotImplementedError
    end

    it "can wait until ready" do
      connection.wait_until_ready # wont raise
    end

    it "provides a default logger" do
      _(connection.method(:logger).call)
        .must_be_instance_of(Logger)
    end

    it "provides direct platform" do
      plat = connection.force_platform!("mac_os_x")
      _(plat.name).must_equal "mac_os_x"
      _(plat.linux?).must_equal false
      _(plat.cloud?).must_equal false
      _(plat.unix?).must_equal true
      _(plat.family).must_equal "darwin"
      _(plat.family_hierarchy).must_equal %w{darwin bsd unix os}
    end

    it "must use the user-provided logger" do
      l = rand
      _(cls.new({ logger: l })
        .method(:logger).call).must_equal(l)
    end

    describe "cached_client helper" do
      class DemoConnection < Train::Plugins::Transport::BaseConnection
        def initialize(options = {})
          super(options)
          @cache_enabled[:api_call] = true
          @cache[:api_call] = {}
        end

        def demo_client
          cached_client(:api_call, :demo_client) do
            DemoClient.new
          end
        end

        class DemoClient
        end
      end

      it "returns a new connection when cached disabled" do
        conn = DemoConnection.new
        conn.disable_cache(:api_call)

        client1 = conn.demo_client
        client2 = conn.demo_client

        _(client1).wont_be_same_as client2
      end

      it "returns a new connection when cache enabled and not hydrated" do
        conn = DemoConnection.new
        conn.enable_cache(:api_call)

        client1 = conn.demo_client

        _(client1).must_be_instance_of DemoConnection::DemoClient
      end

      it "returns a cached connection when cache enabled and hydrated" do
        conn = DemoConnection.new
        conn.enable_cache(:api_call)

        client1 = conn.demo_client
        client2 = conn.demo_client

        _(client1).must_be_same_as client2
      end
    end

    describe "create cache connection" do
      it "default connection cache settings" do
        _(connection.cache_enabled?(:file)).must_equal true
        _(connection.cache_enabled?(:command)).must_equal false
        _(connection.cache_enabled?(:api_call)).must_equal false
      end
    end

    describe "disable/enable caching" do
      it "disable file cache via connection" do
        connection.disable_cache(:file)
        _(connection.cache_enabled?(:file)).must_equal false
      end

      it "enable command cache via cache_connection" do
        connection.enable_cache(:command)
        _(connection.cache_enabled?(:command)).must_equal true
      end

      it "raises an exception for unknown cache type" do
        _ { connection.enable_cache(:fake) }.must_raise Train::UnknownCacheType
        _ { connection.disable_cache(:fake) }.must_raise Train::UnknownCacheType
      end
    end

    describe "cache enable check" do
      it "returns true when cache is enabled" do
        cache_enabled = connection.instance_variable_get(:@cache_enabled)
        cache_enabled[:test] = true
        _(connection.cache_enabled?(:test)).must_equal true
      end

      it "returns false when cache is disabled" do
        cache_enabled = connection.instance_variable_get(:@cache_enabled)
        cache_enabled[:test] = false
        _(connection.cache_enabled?(:test)).must_equal false
      end
    end

    describe "clear cache" do
      it "clear file cache" do
        cache = connection.instance_variable_get(:@cache)
        cache[:file]["/tmp"] = "test"
        connection.send(:clear_cache, :file)
        cache = connection.instance_variable_get(:@cache)
        _(cache[:file]).must_equal({})
      end
    end

    describe "load file" do
      it "with caching" do
        connection.enable_cache(:file)
        connection.expects(:file_via_connection).once.returns("test_file")
        _(connection.file("/tmp/test")).must_equal("test_file")
        _(connection.file("/tmp/test")).must_equal("test_file")
        assert = { "/tmp/test" => "test_file" }
        cache = connection.instance_variable_get(:@cache)
        _(cache[:file]).must_equal(assert)
      end

      it "without caching" do
        connection.disable_cache(:file)
        connection.expects(:file_via_connection).twice.returns("test_file")
        _(connection.file("/tmp/test")).must_equal("test_file")
        _(connection.file("/tmp/test")).must_equal("test_file")
        cache = connection.instance_variable_get(:@cache)
        _(cache[:file]).must_equal({})
      end
    end

    describe "run command" do
      def with_cmd_complete_audit_flag(value)
        original = ENV["TRAIN_ENABLE_CMD_COMPLETE_AUDIT"]

        if value.nil?
          ENV.delete("TRAIN_ENABLE_CMD_COMPLETE_AUDIT")
        else
          ENV["TRAIN_ENABLE_CMD_COMPLETE_AUDIT"] = value
        end

        yield
      ensure
        if original.nil?
          ENV.delete("TRAIN_ENABLE_CMD_COMPLETE_AUDIT")
        else
          ENV["TRAIN_ENABLE_CMD_COMPLETE_AUDIT"] = original
        end
      end

      it "with caching" do
        connection.enable_cache(:command)
        connection.expects(:run_command_via_connection).once.returns("test_user")
        _(connection.run_command("whoami")).must_equal("test_user")
        _(connection.run_command("whoami")).must_equal("test_user")
        assert = { "whoami" => "test_user" }
        cache = connection.instance_variable_get(:@cache)
        _(cache[:command]).must_equal(assert)
      end

      it "without caching" do
        connection.disable_cache(:command)
        connection.expects(:run_command_via_connection).twice.returns("test_user")
        _(connection.run_command("whoami")).must_equal("test_user")
        _(connection.run_command("whoami")).must_equal("test_user")
        cache = connection.instance_variable_get(:@cache)
        _(cache[:command]).must_equal({})
      end

      it "adds command completion telemetry to audit log" do
        with_cmd_complete_audit_flag(nil) do
          audit_events = []
          audit_log = Object.new
          audit_log.define_singleton_method(:info) do |event|
            audit_events << event
          end

          connection.instance_variable_set(:@audit_log, audit_log)
          connection.instance_variable_set(:@audit_log_data, { username: "alice", hostname: "example.test" })

          result = Struct.new(:exit_status).new(7)
          connection.expects(:run_command_via_connection).once.returns(result)

          _(connection.run_command("whoami")).must_equal(result)
          _(audit_events.length).must_equal 2

          cmd_start_event = audit_events[0]
          cmd_complete_event = audit_events[1]

          _(cmd_start_event[:type]).must_equal "cmd"
          _(cmd_start_event[:command]).must_equal "whoami"

          _(cmd_complete_event[:type]).must_equal "cmd_complete"
          _(cmd_complete_event[:command]).must_equal "whoami"
          _(cmd_complete_event[:exit_status]).must_equal 7
          _(cmd_complete_event[:cache_hit]).must_equal false
          _(cmd_complete_event[:user]).must_equal "alice"
          _(cmd_complete_event[:hostname]).must_equal "example.test"
          _(cmd_complete_event[:duration_ms]).must_be_kind_of Numeric
        end
      end

      it "can disable command completion telemetry via feature flag" do
        with_cmd_complete_audit_flag("0") do
          audit_events = []
          audit_log = Object.new
          audit_log.define_singleton_method(:info) do |event|
            audit_events << event
          end

          connection.instance_variable_set(:@audit_log, audit_log)
          connection.instance_variable_set(:@audit_log_data, { username: "alice", hostname: "example.test" })

          result = Struct.new(:exit_status).new(7)
          connection.expects(:run_command_via_connection).once.returns(result)

          _(connection.run_command("whoami")).must_equal(result)
          _(audit_events.length).must_equal 1
          _(audit_events[0][:type]).must_equal "cmd"
        end
      end

      it "respects process-level command completion feature flag mode" do
        audit_events = []
        audit_log = Object.new
        audit_log.define_singleton_method(:info) do |event|
          audit_events << event
        end

        connection.instance_variable_set(:@audit_log, audit_log)
        connection.instance_variable_set(:@audit_log_data, {})

        result = Struct.new(:exit_status).new(0)
        connection.expects(:run_command_via_connection).once.returns(result)

        connection.run_command("whoami")

        completion_events = audit_events.select { |event| event[:type] == "cmd_complete" }
        raw_value = ENV["TRAIN_ENABLE_CMD_COMPLETE_AUDIT"]
        expected_enabled = raw_value.nil? || !%w{0 false no off}.include?(raw_value.to_s.strip.downcase)

        _(completion_events.length).must_equal(expected_enabled ? 1 : 0)
      end

      it "marks command cache hits in completion telemetry" do
        with_cmd_complete_audit_flag("1") do
          audit_events = []
          audit_log = Object.new
          audit_log.define_singleton_method(:info) do |event|
            audit_events << event
          end

          connection.instance_variable_set(:@audit_log, audit_log)
          connection.instance_variable_set(:@audit_log_data, {})

          connection.enable_cache(:command)
          result = Struct.new(:exit_status).new(0)
          connection.expects(:run_command_via_connection).once.returns(result)

          connection.run_command("whoami")
          connection.run_command("whoami")

          completion_events = audit_events.select { |e| e[:type] == "cmd_complete" }
          _(completion_events.length).must_equal 2
          _(completion_events[0][:cache_hit]).must_equal false
          _(completion_events[1][:cache_hit]).must_equal true
        end
      end
    end
  end
end
