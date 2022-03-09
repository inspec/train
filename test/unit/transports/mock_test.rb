require "helper"
require "train/transports/mock"
require "digest/sha2" unless defined?(Digest::SHA2)

describe "mock transport" do
  let(:transport) { Train::Transports::Mock.new(verbose: true) }
  let(:connection) { transport.connection }

  it "can be instantiated" do
    _(transport).wont_be_nil
  end

  it "can create a connection" do
    _(connection).wont_be_nil
  end

  it "provides a uri" do
    _(connection.uri).must_equal "mock://"
  end

  it "provides a run_command_via_connection method" do
    methods = connection.class.private_instance_methods(false)
    _(methods.include?(:run_command_via_connection)).must_equal true
  end

  it "provides a file_via_connection method" do
    methods = connection.class.private_instance_methods(false)
    _(methods.include?(:file_via_connection)).must_equal true
  end

  describe "when running a mocked command" do
    let(:mock_cmd) {}

    it "has a simple mock command creator" do
      out = rand
      cls = Train::Transports::Mock::Connection::Command
      res = cls.new(out, "", 0)
      _(connection.mock_command("test", out)).must_equal res
    end

    it "handles nil commands" do
      assert_output "", /Command not mocked/ do
        _(connection.run_command(nil).stdout).must_equal("")
      end
    end

    it "can mock up nil commands" do
      out = rand
      connection.mock_command("", rand) # don't pull this result! always mock the input
      connection.mock_command(nil, out) # pull this result
      _(connection.run_command(nil).stdout).must_equal(out)
    end

    it "gets results for stdout" do
      out = rand
      cmd = rand
      connection.mock_command(cmd, out)
      _(connection.run_command(cmd).stdout).must_equal(out)
    end

    it "gets results for stderr" do
      err = rand
      cmd = rand
      connection.mock_command(cmd, nil, err)
      _(connection.run_command(cmd).stderr).must_equal(err)
    end

    it "gets results for exit_status" do
      code = rand
      cmd = rand
      connection.mock_command(cmd, nil, nil, code)
      _(connection.run_command(cmd).exit_status).must_equal(code)
    end

    it "can mock a command via its SHA2 sum" do
      out = rand.to_s
      cmd = rand.to_s
      shacmd = Digest::SHA256.hexdigest cmd
      connection.mock_command(shacmd, out)
      _(connection.run_command(cmd).stdout).must_equal(out)
    end
  end

  describe "when accessing a mocked os" do
    it "has the default mock os faily set to mock" do
      _(connection.os[:name]).must_equal "mock"
      _(connection.platform[:name]).must_equal "mock"
    end

    it "sets the OS to the mocked value" do
      connection.mock_os({ name: "centos", family: "redhat" })
      _(connection.os.linux?).must_equal true
      _(connection.os.redhat?).must_equal true
      _(connection.os[:family]).must_equal "redhat"
    end

    it "allows the setting of the name" do
      connection.mock_os({ name: "foo" })
      _(connection.os[:name]).must_equal "foo"
    end

    it "allows setting of the family" do
      connection.mock_os({ family: "foo" })
      _(connection.os[:family]).must_equal "foo"
    end

    it "allows setting of the release" do
      connection.mock_os({ release: "1.2.3" })
      _(connection.os[:release]).must_equal "1.2.3"
    end

    it "allows setting of the arch" do
      connection.mock_os({ arch: "amd123" })
      _(connection.os[:arch]).must_equal "amd123"
    end

    it "allow setting of multiple values" do
      connection.mock_os({ name: "foo", family: "bar" })
      _(connection.os[:name]).must_equal "foo"
      _(connection.os[:family]).must_equal "bar"
      _(connection.os[:arch]).must_equal "unknown"
      _(connection.os[:release]).must_equal "unknown"
    end

    it "properly handles a nil value" do
      connection.mock_os(nil)
      _(connection.os[:name]).must_equal "mock"
      _(connection.os[:family]).must_equal "mock"
    end

    it "rauses error for default mock os uuid" do
      _(connection.os[:name]).must_equal "mock"
      _(connection.platform[:name]).must_equal "mock"
      err = _ { connection.platform[:uuid] }.must_raise Train::PlatformUuidDetectionFailed
      _(err.message).must_match("Could not find platform uuid! Please set a uuid_command for your platform.")
    end
  end

  describe "when accessing a mocked file" do
    it "handles a non-existing file" do
      x = rand.to_s
      assert_output "", /File not mocked/ do
        f = connection.file(x)
        _(f).must_be_kind_of Train::Transports::Mock::Connection::File
        _(f.exist?).must_equal false
        _(f.path).must_equal x
      end
    end

    # tests if all fields between the local json and resulting mock file
    # are equal
    JSON_DATA = Train.create("local").connection.file(__FILE__).to_json
    RES = Train::Transports::Mock::Connection::File.from_json(JSON_DATA)
    %w{ content mode owner group }.each do |f|
      it "can be initialized from json (field #{f})" do
        r = RES.send(f)
        d = JSON_DATA[f]
        if d
          _(r).must_equal d
        else
          _(r).must_be_nil # I think just group on windows
        end
      end
    end
  end
end
