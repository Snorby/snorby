require 'spec_helper'

describe "lookups/show.html.erb" do
  before(:each) do
    @lookup = assign(:lookup, stub_model(Lookup))
  end

  it "renders attributes in <p>" do
    render
  end
end
