# encoding: utf-8

require "helper"

describe "platform family" do
  def mock_family(x)
    Train::Platforms.families[x] = nil if x == "mock"
    Train::Platforms.family(x)
  end

  it "set family title" do
    plat = mock_family("mock")
    plat.title.must_equal("Mock Family")
    plat.title("The Best Mock Family")
    plat.title.must_equal("The Best Mock Family")
  end

  it "set family in a family" do
    plat = mock_family("family1")
    plat.in_family("family2")
    plat.families.keys[0].name.must_equal("family2")

    plat = mock_family("family2")
    plat.children.keys[0].name.must_equal("family1")
  end

  it "set family in a family with condition" do
    plat = Train::Platforms.family("family4", arch: "= x68_64").in_family("family5")
    plat.families.keys[0].name.must_equal("family5")
    plat.families.values[0].must_equal({ arch: "= x68_64" })
  end
end
