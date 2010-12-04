require 'spec_helper'

describe "notifications/edit.html.erb" do
  before(:each) do
    @notification = assign(:notification, stub_model(Notification,
      :new_record? => false,
      :title => "MyString",
      :description => "MyText",
      :sig_id => 1,
      :ip_src => 1,
      :ip_dst => 1,
      :user_ids => 1,
      :sensor_ids => 1
    ))
  end

  it "renders the edit notification form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => notification_path(@notification), :method => "post" do
      assert_select "input#notification_title", :name => "notification[title]"
      assert_select "textarea#notification_description", :name => "notification[description]"
      assert_select "input#notification_sig_id", :name => "notification[sig_id]"
      assert_select "input#notification_ip_src", :name => "notification[ip_src]"
      assert_select "input#notification_ip_dst", :name => "notification[ip_dst]"
      assert_select "input#notification_user_ids", :name => "notification[user_ids]"
      assert_select "input#notification_sensor_ids", :name => "notification[sensor_ids]"
    end
  end
end
