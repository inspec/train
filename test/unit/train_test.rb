#
# Author:: Dominik Richter (<dominik.richter@gmail.com>)
require "helper"

$:.concat Dir["test/fixtures/plugins/*/lib"] # HACK? I honestly can't tell

describe Train do
  before do
    Train::Plugins.registry.clear
  end

  describe "#create" do
    it "raises an error if the plugin isnt found" do
      _ { Train.create("missing") }.must_raise Train::UserError
      _ { Train.create("missing") }.must_raise Train::PluginLoadError
    end

    it "loads a core plugin if it isnt in the registry yet via symbol" do
      Kernel.stub :require, true do
        ex = Class.new(Train.plugin 1) { name "existing" }
        train = Train.create(:existing)
        _(train.class).must_equal ex
      end
    end

    it "loads a core plugin if it isnt in the registry yet via string" do
      Kernel.stub :require, true do
        ex = Class.new(Train.plugin 1) { name "existing" }
        train = Train.create("existing")
        _(train.class).must_equal ex
      end
    end

    it "loads a gem plugin if it isnt in the registry yet via string" do
      # The 'train-test-fixture' gem is located in test/fixtures/plugins/train-test-fixture and is
      # lib/train/trainsports, and Train will need to pre-pend 'train-' to the
      # transport name to get the gem name.
      transport = Train.create("test-fixture")
      # Normally one would call transport.class.name, but that's been overridden to be a write-only DSL method
      # So use to_s
      _(transport.class.to_s).must_equal "TrainPlugins::TestFixture::Transport"
    end
  end

  describe "#options" do
    it "raises exception if a given transport plugin isnt found" do
      _ { Train.options("missing") }.must_raise Train::UserError
      _ { Train.options("missing") }.must_raise Train::PluginLoadError
    end

    it "provides empty options of a transport plugin" do
      Class.new(Train.plugin 1) { name "none" }
      _(Train.options("none")).must_equal({})
    end

    it "provides all options of a transport plugin" do
      Class.new(Train.plugin 1) do
        name "one"
        option :one, required: true, default: 123
      end
      _(Train.options("one")).must_equal({
        one: {
          required: true,
          default: 123,
        },
      })
    end
  end

  describe "#target_config - URI parsing" do
    it "configures resolves target" do
      org = {
        target: "ssh://user:pass@host.com:123/path",
      }
      res = Train.target_config(org)
      _(res[:backend]).must_equal "ssh"
      _(res[:host]).must_equal "host.com"
      _(res[:user]).must_equal "user"
      _(res[:password]).must_equal "pass"
      _(res[:port]).must_equal 123
      _(res[:target]).must_equal org[:target]
      _(res[:path]).must_equal "/path"
      _(org.keys).must_equal [:target]
    end

    it "resolves a target while keeping existing fields" do
      org = {
        target: "ssh://user:pass@host.com:123/path",
        backend: rand,
        host: rand,
        user: rand,
        password: rand,
        port: rand,
        path: rand,
      }
      res = Train.target_config(org)
      _(res).must_equal org
    end

    it "resolves a winrm target" do
      org = {
        target: "winrm://Administrator@192.168.10.140",
        backend: "winrm",
        host: "192.168.10.140",
        user: "Administrator",
        password: nil,
        port: nil,
        path: nil,
      }
      res = Train.target_config(org)
      _(res).must_equal org
    end

    it "keeps the configuration when incorrect target is supplied" do
      org = {
        target: "wrong",
      }
      res = Train.target_config(org)
      _(res[:backend]).must_be_nil
      _(res[:host]).must_be_nil
      _(res[:user]).must_be_nil
      _(res[:password]).must_be_nil
      _(res[:port]).must_be_nil
      _(res[:path]).must_be_nil
      _(res[:target]).must_equal org[:target]
    end

    it "always transforms config fields into ruby symbols" do
      org = {
        "target" => "ssh://user:pass@host.com:123/path",
        "backend" => rand,
        "host" => rand,
        "user" => rand,
        "password" => rand,
        "port" => rand,
        "path" => rand,
      }
      nu = org.each_with_object({}) do |(x, y), acc|
        acc[x.to_sym] = y; acc
      end
      res = Train.target_config(org)
      _(res).must_equal nu
    end

    it "supports IPv4 URIs" do
      org = { target: "mock://1.2.3.4:123" }
      res = Train.target_config(org)
      _(res[:backend]).must_equal "mock"
      _(res[:host]).must_equal "1.2.3.4"
      _(res[:user]).must_be_nil
      _(res[:password]).must_be_nil
      _(res[:port]).must_equal 123
      _(res[:path]).must_be_nil
      _(res[:target]).must_equal org[:target]
    end

    it "supports IPv6 URIs (with brackets)" do
      org = { target: "mock://[abc::def]:123" }
      res = Train.target_config(org)
      _(res[:backend]).must_equal "mock"
      _(res[:host]).must_equal "abc::def"
      _(res[:user]).must_be_nil
      _(res[:password]).must_be_nil
      _(res[:port]).must_equal 123
      _(res[:path]).must_be_nil
      _(res[:target]).must_equal org[:target]
    end

    it "supports IPv6 URIs (without brackets)" do
      org = { target: "mock://FEDC:BA98:7654:3210:FEDC:BA98:7654:3210:123" }
      res = Train.target_config(org)
      _(res[:backend]).must_equal "mock"
      _(res[:host]).must_equal "FEDC:BA98:7654:3210:FEDC:BA98:7654:3210"
      _(res[:user]).must_be_nil
      _(res[:password]).must_be_nil
      _(res[:port]).must_equal 123
      _(res[:path]).must_be_nil
      _(res[:target]).must_equal org[:target]
    end

    it "supports empty URIs with schema://" do
      org = { target: "mock://" }
      res = Train.target_config(org)
      _(res[:backend]).must_equal "mock"
      _(res[:host]).must_be_nil
      _(res[:user]).must_be_nil
      _(res[:password]).must_be_nil
      _(res[:port]).must_be_nil
      _(res[:path]).must_be_nil
      _(res[:target]).must_equal org[:target]
    end

    it "supports empty URIs with schema:" do
      org = { target: "mock:" }
      res = Train.target_config(org)
      _(res[:backend]).must_equal "mock"
      _(res[:host]).must_be_nil
      _(res[:user]).must_be_nil
      _(res[:password]).must_be_nil
      _(res[:port]).must_be_nil
      _(res[:path]).must_be_nil
      _(res[:target]).must_equal org[:target]
    end

    it "supports www-form encoded passwords when the option is set" do
      raw_password = '+!@#$%^&*()_-\';:"\\|/?.>,<][}{=`~'
      encoded_password = Addressable::URI.normalize_component(raw_password, Addressable::URI::CharacterClasses::UNRESERVED)
      org = { target: "mock://username:#{encoded_password}@1.2.3.4:100",
              www_form_encoded_password: true }
      res = Train.target_config(org)
      _(res[:backend]).must_equal "mock"
      _(res[:host]).must_equal "1.2.3.4"
      _(res[:user]).must_equal "username"
      _(res[:password]).must_equal raw_password
      _(res[:port]).must_equal 100
      _(res[:target]).must_equal org[:target]
    end

    it "ignores www-form-encoded password value when there is no password" do
      org = { target: "mock://username@1.2.3.4:100",
              www_form_encoded_password: true }
      res = Train.target_config(org)
      _(res[:backend]).must_equal "mock"
      _(res[:host]).must_equal "1.2.3.4"
      _(res[:user]).must_equal "username"
      _(res[:password]).must_be_nil
      _(res[:port]).must_equal 100
      _(res[:target]).must_equal org[:target]
    end

    it "it raises UserError on invalid URIs (invalid scheme)" do
      org = { target: "123://invalid_scheme.example.com/" }
      _ { Train.target_config(org) }.must_raise Train::UserError
    end
  end

  describe "#validate_backend" do
    it "just returns the backend if it is provided" do
      x = rand
      _(Train.validate_backend({ backend: x })).must_equal x
    end

    it "returns the local backend if nothing was provided" do
      _(Train.validate_backend({})).must_equal "local"
    end

    it "returns the default backend if nothing was provided" do
      x = rand
      _(Train.validate_backend({}, x)).must_equal x
    end

    it "fails if no backend was given but a target is provided" do
      _ { Train.validate_backend({ target: rand }) }.must_raise Train::UserError
    end

    it "fails if no backend was given but a host is provided" do
      _ { Train.validate_backend({ host: rand }) }.must_raise Train::UserError
    end
  end
end
