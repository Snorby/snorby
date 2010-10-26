require 'spec_helper'

describe "classifications/index.html.erb" do
  before(:each) do
    assign(:classifications, [
      stub_model(Classification),
      stub_model(Classification)
    ])
  end

  it "renders a list of classifications" do
    render
  end
end
