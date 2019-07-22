# encoding: utf-8

require "helper"

describe "platforms" do

  it "create platform" do
    Train::Platforms.list["mock"] = nil
    plat = Train::Platforms.name("mock")
    Train::Platforms.name("mock").in_family("test")
    Train::Platforms.name("mock").detect { true }
    plat.title.must_equal("Mock")
    plat.detect.call.must_equal(true)
    plat.families.keys[0].name.must_equal("test")
  end

  it "create family" do
    Train::Platforms.families["mock"] = nil
    fam = Train::Platforms.family("mock")
    Train::Platforms.family("mock").in_family("test")
    Train::Platforms.family("mock").detect { true }
    fam.title.must_equal("Mock Family")
    fam.detect.call.must_equal(true)
    fam.families.keys[0].name.must_equal("test")
  end

  it "return top platforms empty" do
    Train::Platforms.stubs(:list).returns({})
    Train::Platforms.stubs(:families).returns({})
    top = Train::Platforms.top_platforms
    top.count.must_equal(0)
  end

  it "return top platforms with data" do
    plat = Train::Platforms.name("linux")
    plat.stubs(:families).returns({})
    Train::Platforms.stubs(:list).returns({ "linux" => plat })
    Train::Platforms.stubs(:families).returns({})
    top = Train::Platforms.top_platforms
    top.count.must_equal(1)
  end

  it "return platforms export with data" do
    export = Train::Platforms.export
    export.size.must_be :>, 10
    export[0][:name].must_equal "aix"
    expected_families = %w{aix unix os}
    export[0][:families].must_equal expected_families
  end
end
