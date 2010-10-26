require 'spec_helper'

describe "classifications/show.html.erb" do
  before(:each) do
    @classification = assign(:classification, stub_model(Classification))
  end

  it "renders attributes in <p>" do
    render
  end
end
