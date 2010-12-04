require 'spec_helper'

describe "notifications/index.html.erb" do
  before(:each) do
    assign(:notifications, [
      stub_model(Notification,
        :title => "Title",
        :description => "MyText",
        :sig_id => 1,
        :ip_src => 1,
        :ip_dst => 1,
        :user_ids => 1,
        :sensor_ids => 1
      ),
      stub_model(Notification,
        :title => "Title",
        :description => "MyText",
        :sig_id => 1,
        :ip_src => 1,
        :ip_dst => 1,
        :user_ids => 1,
        :sensor_ids => 1
      )
    ])
  end

  it "renders a list of notifications" do
    render
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
