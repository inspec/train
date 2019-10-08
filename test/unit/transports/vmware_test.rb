# encoding: utf-8
require "helper"
require "train/transports/vmware"

describe "Train::Transports::VMware::Connection" do
  def add_stubs(stub_options)
    Train::Transports::VMware::Connection.any_instance
      .stubs(:detect_powershell_binary)
      .returns(stub_options[:powershell_binary] || :pwsh)
    Train::Transports::VMware::Connection.any_instance
      .stubs(:powercli_version)
      .returns("10.1.1.8827525")
    Train::Transports::VMware::Connection.any_instance
      .stubs(:run_command_via_connection)
      .with("(Get-VMHost | Get-View).hardware.systeminfo.uuid")
      .returns(stub_options[:mock_uuid_result] || nil)
    if stub_options[:mock_connect_result]
      Train::Transports::VMware::Connection.any_instance
        .expects(:run_command_via_connection)
        .with("Connect-VIServer 10.0.0.10 -User testuser -Password supersecurepassword | Out-Null")
        .returns(stub_options[:mock_connect_result])
    else
      Train::Transports::VMware::Connection.any_instance
        .stubs(:connect)
        .returns(nil)
    end
  end

  def create_transport(options = {})
    ENV["VISERVER"] = "10.0.0.10"
    ENV["VISERVER_USERNAME"] = "testuser"
    ENV["VISERVER_PASSWORD"] = "supersecurepassword"

    add_stubs(options[:stub_options] || {})
    Train::Transports::VMware.new(options[:transport_options])
  end

  describe "#initialize" do
    it "defaults to ENV options" do
      options = create_transport.connection.instance_variable_get(:@options)
      _(options[:viserver]).must_equal "10.0.0.10"
      _(options[:username]).must_equal "testuser"
      _(options[:password]).must_equal "supersecurepassword"
      _(options[:insecure]).must_equal false
    end

    it "allows for overriding options" do
      transport = create_transport(
        transport_options: {
          viserver: "10.1.1.1",
          username: "anotheruser",
          password: "notsecurepassword",
          insecure: false,
        }
      )
      options = transport.connection.instance_variable_get(:@options)
      _(options[:viserver]).must_equal "10.1.1.1"
      _(options[:username]).must_equal "anotheruser"
      _(options[:password]).must_equal "notsecurepassword"
      _(options[:insecure]).must_equal false
    end

    it "ignores certificate validation if --insecure is used" do
      Train::Transports::VMware::Connection.any_instance
        .expects(:run_command_via_connection)
        .with("Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Scope Session -Confirm:$False")
        .returns(nil)
      transport = create_transport(transport_options: { insecure: true })
      options = transport.connection.instance_variable_get(:@options)
      _(options[:insecure]).must_equal true
    end

    it "uses the Local connection when Windows PowerShell is found" do
      require "train/transports/local"
      Train::Transports::Local::Connection.expects(:new)
      create_transport(
        stub_options: {
          powershell_binary: :powershell,
        }
      ).connection
    end
  end

  # rubocop:disable Style/BlockDelimiters

  describe "#connect" do
    def mock_connect_result(stderr, exit_status)
      OpenStruct.new(stderr: stderr, exit_status: exit_status)
    end

    it "raises certificate error when stderr matches regular expression" do
      e = _ {
        create_transport(
          stub_options: {
            mock_connect_result: mock_connect_result(
              "Invalid server certificate", 1
            ),
          }
        ).connection
      }.must_raise(RuntimeError)
      _(e.message).must_match(/Unable to connect.*Please use `--insecure`/)
    end

    it "raises auth error when stderr matches regular expression" do
      e = _ {
        create_transport(
          stub_options: {
            mock_connect_result: mock_connect_result(
              "incorrect user name or password", 1
            ),
          }
        ).connection
      }.must_raise(RuntimeError)
      _(e.message).must_match(/Unable to connect.*Incorrect username/)
    end

    it "redacts the password when an unspecified error is raised" do
      e = _ {
        create_transport(
          stub_options: {
            mock_connect_result: mock_connect_result(
              "something unexpected -Password supersecret -AnotherOption", 1
            ),
          }
        ).connection
      }.must_raise(RuntimeError)
      _(e.message).must_match(/-Password REDACTED/)
    end
  end

  describe "#platform" do
    it "returns correct platform details" do
      platform = create_transport.connection.platform
      _(platform.clean_name).must_equal "vmware"
      _(platform.family_hierarchy).must_equal %w{cloud api}
      _(platform.platform).must_equal(release: "vmware-powercli-10.1.1.8827525")
      _(platform.vmware?).must_equal true
    end
  end

  describe "#unique_identifier" do
    it "returns the correct unique identifier" do
      uuid = "1f261432-e23e-6911-841c-94c6911a02dd"
      mock_uuid_result = OpenStruct.new(
        stdout: uuid + "\n"
      )
      connection = create_transport(
        stub_options: { mock_uuid_result: mock_uuid_result }
      ).connection

      _(connection.unique_identifier).must_equal(uuid)
    end
  end

  describe "#uri" do
    it "returns the correct URI" do
      _(create_transport.connection.uri).must_equal "vmware://testuser@10.0.0.10"
    end
  end
end
