require 'spec_helper'

describe LookupsController do

  def mock_lookup(stubs={})
    (@mock_lookup ||= mock_model(Lookup).as_null_object).tap do |lookup|
      lookup.stub(stubs) unless stubs.empty?
    end
  end

  describe "GET index" do
    it "assigns all lookups as @lookups" do
      Lookup.stub(:all) { [mock_lookup] }
      get :index
      assigns(:lookups).should eq([mock_lookup])
    end
  end

  describe "GET show" do
    it "assigns the requested lookup as @lookup" do
      Lookup.stub(:get).with("37") { mock_lookup }
      get :show, :id => "37"
      assigns(:lookup).should be(mock_lookup)
    end
  end

  describe "GET new" do
    it "assigns a new lookup as @lookup" do
      Lookup.stub(:new) { mock_lookup }
      get :new
      assigns(:lookup).should be(mock_lookup)
    end
  end

  describe "GET edit" do
    it "assigns the requested lookup as @lookup" do
      Lookup.stub(:get).with("37") { mock_lookup }
      get :edit, :id => "37"
      assigns(:lookup).should be(mock_lookup)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created lookup as @lookup" do
        Lookup.stub(:new).with({'these' => 'params'}) { mock_lookup(:save => true) }
        post :create, :lookup => {'these' => 'params'}
        assigns(:lookup).should be(mock_lookup)
      end

      it "redirects to the created lookup" do
        Lookup.stub(:new) { mock_lookup(:save => true) }
        post :create, :lookup => {}
        response.should redirect_to(lookup_url(mock_lookup))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved lookup as @lookup" do
        Lookup.stub(:new).with({'these' => 'params'}) { mock_lookup(:save => false) }
        post :create, :lookup => {'these' => 'params'}
        assigns(:lookup).should be(mock_lookup)
      end

      it "re-renders the 'new' template" do
        Lookup.stub(:new) { mock_lookup(:save => false) }
        post :create, :lookup => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested lookup" do
        Lookup.should_receive(:get).with("37") { mock_lookup }
        mock_lookup.should_receive(:update).with({'these' => 'params'})
        put :update, :id => "37", :lookup => {'these' => 'params'}
      end

      it "assigns the requested lookup as @lookup" do
        Lookup.stub(:get) { mock_lookup(:update => true) }
        put :update, :id => "1"
        assigns(:lookup).should be(mock_lookup)
      end

      it "redirects to the lookup" do
        Lookup.stub(:get) { mock_lookup(:update => true) }
        put :update, :id => "1"
        response.should redirect_to(lookup_url(mock_lookup))
      end
    end

    describe "with invalid params" do
      it "assigns the lookup as @lookup" do
        Lookup.stub(:get) { mock_lookup(:update => false) }
        put :update, :id => "1"
        assigns(:lookup).should be(mock_lookup)
      end

      it "re-renders the 'edit' template" do
        Lookup.stub(:get) { mock_lookup(:update => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested lookup" do
      Lookup.should_receive(:get).with("37") { mock_lookup }
      mock_lookup.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the lookups list" do
      Lookup.stub(:get) { mock_lookup }
      delete :destroy, :id => "1"
      response.should redirect_to(lookups_url)
    end
  end

end
