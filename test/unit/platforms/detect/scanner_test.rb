# encoding: utf-8

require "helper"
require "train/platforms/detect/scanner"
require "train/transports/mock"

describe "scanner" do
  let(:backend) { Train::Transports::Mock::Connection.new }
  let(:scanner) { Train::Platforms::Detect::Scanner.new(backend) }

  describe "scan family children" do
    it "return child" do
      family = Train::Platforms.family("linux")
      _(scanner.scan_family_children(family).name).must_equal("linux")
      _(scanner.instance_variable_get(:@family_hierarchy)).must_equal(["linux"])
    end

    it "return nil" do
      family = Train::Platforms.family("fake-fam")
      _(scanner.scan_family_children(family)).must_be_nil
      _(scanner.instance_variable_get(:@family_hierarchy)).must_be_empty
    end
  end

  describe "check condition" do
    it "return true equal" do
      scanner.instance_variable_set(:@platform, { arch: "x86_64" })
      _(scanner.check_condition({ arch: "= x86_64" })).must_equal(true)
    end

    it "return true greater then" do
      scanner.instance_variable_set(:@platform, { release: "8.2" })
      _(scanner.check_condition({ release: ">= 7" })).must_equal(true)
    end

    it "return false greater then" do
      scanner.instance_variable_set(:@platform, { release: "2.2" })
      _(scanner.check_condition({ release: "> 7" })).must_equal(false)
    end
  end

  describe "get platform" do
    it "return empty platform" do
      plat = Train::Platforms.name("linux")
      plat = scanner.get_platform(plat)
      _(plat.platform).must_equal({})
      _(plat.backend).must_equal(backend)
      _(plat.family_hierarchy).must_equal([])
    end

    it "return full platform" do
      scanner.instance_variable_set(:@platform, { family: "linux" })
      scanner.instance_variable_set(:@family_hierarchy, %w{linux unix})
      plat = Train::Platforms.name("linux")
      plat = scanner.get_platform(plat)
      _(plat.platform).must_equal({ family: "linux" })
      _(plat.backend).must_equal(backend)
      _(plat.family_hierarchy).must_equal(%w{linux unix})
    end
  end
end
