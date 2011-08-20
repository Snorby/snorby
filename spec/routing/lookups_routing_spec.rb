require "spec_helper"

describe LookupsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/lookups" }.should route_to(:controller => "lookups", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/lookups/new" }.should route_to(:controller => "lookups", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/lookups/1" }.should route_to(:controller => "lookups", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/lookups/1/edit" }.should route_to(:controller => "lookups", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/lookups" }.should route_to(:controller => "lookups", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/lookups/1" }.should route_to(:controller => "lookups", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/lookups/1" }.should route_to(:controller => "lookups", :action => "destroy", :id => "1")
    end

  end
end
