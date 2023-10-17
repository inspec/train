require "helper"

describe "v1 Transport Plugin" do
  let(:default_options) {
    {
      enable_audit_log: false,
      audit_log_location: $stdout,
      audit_log_app_name: "train",
      audit_log_size: 2000000,
      audit_log_frequency: "daily",
    }
  }

  describe "empty v1 transport plugin" do
    let(:plugin) { Class.new(Train.plugin(1)) }
    it "initializes an empty configuration" do
      _(plugin.new.options).must_equal(default_options)
    end

    it "saves the provided configuration" do
      conf = default_options.merge({ a: rand })
      _(plugin.new(conf).options).must_equal(conf)
    end

    it "saves the provided configuration" do
      conf = default_options.merge({ a: rand })
      _(plugin.new(conf).options).must_equal(conf)
    end

    it "provides a default logger" do
      conf = { a: rand }
      _(plugin.new(conf)
        .method(:logger).call)
        .must_be_instance_of(Logger)
    end

    it "can configure custom loggers" do
      l = rand
      _(plugin.new({ logger: l })
        .method(:logger).call)
        .must_equal(l)
    end

    it "provides a connection method" do
      _ { plugin.new.connection }.must_raise Train::ClientError
    end
  end

  describe "registered with a name" do
    before do
      Train::Plugins.registry.clear
    end

    it "doesnt have any plugins in the registry if none were configured" do
      _(Train::Plugins.registry.empty?).must_equal true
    end

    it "is is added to the plugins registry" do
      plugin_name = rand
      _(Train::Plugins.registry).wont_include(plugin_name)

      plugin = Class.new(Train.plugin(1)) do
        name plugin_name
      end

      _(Train::Plugins.registry[plugin_name]).must_equal(plugin)
    end
  end

  describe "with options" do
    def train_class(opts = {})
      name = rand.to_s
      plugin = Class.new(Train.plugin(1)) do
        option name, opts
      end
      [name, plugin]
    end

    it "exposes the parameters via api" do
      name, plugin = train_class
      output = default_options.keys << name
      _(plugin.default_options.keys).must_equal output
    end

    it "exposes the parameters via api" do
      default = rand.to_s
      name, plugin = train_class({ default: default })
      _(plugin.default_options[name][:default]).must_equal default
    end

    it "option must be required" do
      name, plugin = train_class(required: true)
      _(plugin.default_options[name][:required]).must_equal true
    end

    it "default option must not be required" do
      name, plugin = train_class
      _(plugin.default_options[name][:required]).must_be_nil
    end

    it "can include options from another module" do
      name_a, plugin_a = train_class
      b = Class.new(Train.plugin(1)) do
        include_options(plugin_a)
      end
      _(b.default_options[name_a]).wont_be_nil
    end

    it "overwrites existing options when including" do
      old = rand.to_s
      nu = rand.to_s
      name_a, plugin_a = train_class({ default: nu })
      b = Class.new(Train.plugin(1)) do
        option name_a, default: old
        include_options(plugin_a)
      end
      _(b.default_options[name_a][:default]).must_equal nu
    end
  end
end
