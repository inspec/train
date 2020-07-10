require "helper"

describe Train do
  it "defines a version" do
    _(Train::VERSION).must_be_instance_of String
  end
end
