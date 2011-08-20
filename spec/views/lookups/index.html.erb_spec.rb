require 'spec_helper'

describe "lookups/index.html.erb" do
  before(:each) do
    assign(:lookups, [
      stub_model(Lookup),
      stub_model(Lookup)
    ])
  end

  it "renders a list of lookups" do
    render
  end
end
