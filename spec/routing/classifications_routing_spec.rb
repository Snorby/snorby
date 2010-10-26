require "spec_helper"

describe ClassificationsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/classifications" }.should route_to(:controller => "classifications", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/classifications/new" }.should route_to(:controller => "classifications", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/classifications/1" }.should route_to(:controller => "classifications", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/classifications/1/edit" }.should route_to(:controller => "classifications", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/classifications" }.should route_to(:controller => "classifications", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/classifications/1" }.should route_to(:controller => "classifications", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/classifications/1" }.should route_to(:controller => "classifications", :action => "destroy", :id => "1")
    end

  end
end
