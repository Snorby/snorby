require 'spec_helper'

describe ClassificationsController do

  def mock_classification(stubs={})
    (@mock_classification ||= mock_model(Classification).as_null_object).tap do |classification|
      classification.stub(stubs) unless stubs.empty?
    end
  end

  describe "GET index" do
    it "assigns all classifications as @classifications" do
      Classification.stub(:all) { [mock_classification] }
      get :index
      assigns(:classifications).should eq([mock_classification])
    end
  end

  describe "GET show" do
    it "assigns the requested classification as @classification" do
      Classification.stub(:get).with("37") { mock_classification }
      get :show, :id => "37"
      assigns(:classification).should be(mock_classification)
    end
  end

  describe "GET new" do
    it "assigns a new classification as @classification" do
      Classification.stub(:new) { mock_classification }
      get :new
      assigns(:classification).should be(mock_classification)
    end
  end

  describe "GET edit" do
    it "assigns the requested classification as @classification" do
      Classification.stub(:get).with("37") { mock_classification }
      get :edit, :id => "37"
      assigns(:classification).should be(mock_classification)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created classification as @classification" do
        Classification.stub(:new).with({'these' => 'params'}) { mock_classification(:save => true) }
        post :create, :classification => {'these' => 'params'}
        assigns(:classification).should be(mock_classification)
      end

      it "redirects to the created classification" do
        Classification.stub(:new) { mock_classification(:save => true) }
        post :create, :classification => {}
        response.should redirect_to(classification_url(mock_classification))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved classification as @classification" do
        Classification.stub(:new).with({'these' => 'params'}) { mock_classification(:save => false) }
        post :create, :classification => {'these' => 'params'}
        assigns(:classification).should be(mock_classification)
      end

      it "re-renders the 'new' template" do
        Classification.stub(:new) { mock_classification(:save => false) }
        post :create, :classification => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested classification" do
        Classification.should_receive(:get).with("37") { mock_classification }
        mock_classification.should_receive(:update).with({'these' => 'params'})
        put :update, :id => "37", :classification => {'these' => 'params'}
      end

      it "assigns the requested classification as @classification" do
        Classification.stub(:get) { mock_classification(:update => true) }
        put :update, :id => "1"
        assigns(:classification).should be(mock_classification)
      end

      it "redirects to the classification" do
        Classification.stub(:get) { mock_classification(:update => true) }
        put :update, :id => "1"
        response.should redirect_to(classification_url(mock_classification))
      end
    end

    describe "with invalid params" do
      it "assigns the classification as @classification" do
        Classification.stub(:get) { mock_classification(:update => false) }
        put :update, :id => "1"
        assigns(:classification).should be(mock_classification)
      end

      it "re-renders the 'edit' template" do
        Classification.stub(:get) { mock_classification(:update => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested classification" do
      Classification.should_receive(:get).with("37") { mock_classification }
      mock_classification.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the classifications list" do
      Classification.stub(:get) { mock_classification }
      delete :destroy, :id => "1"
      response.should redirect_to(classifications_url)
    end
  end

end
