require 'spec_helper'

describe "lookups/new.html.erb" do
  before(:each) do
    assign(:lookup, stub_model(Lookup).as_new_record)
  end

  it "renders new lookup form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => lookups_path, :method => "post" do
    end
  end
end
