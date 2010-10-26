require 'spec_helper'

describe "classifications/edit.html.erb" do
  before(:each) do
    @classification = assign(:classification, stub_model(Classification,
      :new_record? => false
    ))
  end

  it "renders the edit classification form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => classification_path(@classification), :method => "post" do
    end
  end
end
