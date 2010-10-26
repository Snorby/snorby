require 'spec_helper'

describe "classifications/new.html.erb" do
  before(:each) do
    assign(:classification, stub_model(Classification).as_new_record)
  end

  it "renders new classification form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => classifications_path, :method => "post" do
    end
  end
end
