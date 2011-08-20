require 'spec_helper'

describe "lookups/edit.html.erb" do
  before(:each) do
    @lookup = assign(:lookup, stub_model(Lookup,
      :new_record? => false
    ))
  end

  it "renders the edit lookup form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => lookup_path(@lookup), :method => "post" do
    end
  end
end
