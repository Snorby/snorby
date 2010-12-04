require 'spec_helper'

describe NotificationsController do

  def mock_notification(stubs={})
    (@mock_notification ||= mock_model(Notification).as_null_object).tap do |notification|
      notification.stub(stubs) unless stubs.empty?
    end
  end

  describe "GET index" do
    it "assigns all notifications as @notifications" do
      Notification.stub(:all) { [mock_notification] }
      get :index
      assigns(:notifications).should eq([mock_notification])
    end
  end

  describe "GET show" do
    it "assigns the requested notification as @notification" do
      Notification.stub(:get).with("37") { mock_notification }
      get :show, :id => "37"
      assigns(:notification).should be(mock_notification)
    end
  end

  describe "GET new" do
    it "assigns a new notification as @notification" do
      Notification.stub(:new) { mock_notification }
      get :new
      assigns(:notification).should be(mock_notification)
    end
  end

  describe "GET edit" do
    it "assigns the requested notification as @notification" do
      Notification.stub(:get).with("37") { mock_notification }
      get :edit, :id => "37"
      assigns(:notification).should be(mock_notification)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created notification as @notification" do
        Notification.stub(:new).with({'these' => 'params'}) { mock_notification(:save => true) }
        post :create, :notification => {'these' => 'params'}
        assigns(:notification).should be(mock_notification)
      end

      it "redirects to the created notification" do
        Notification.stub(:new) { mock_notification(:save => true) }
        post :create, :notification => {}
        response.should redirect_to(notification_url(mock_notification))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved notification as @notification" do
        Notification.stub(:new).with({'these' => 'params'}) { mock_notification(:save => false) }
        post :create, :notification => {'these' => 'params'}
        assigns(:notification).should be(mock_notification)
      end

      it "re-renders the 'new' template" do
        Notification.stub(:new) { mock_notification(:save => false) }
        post :create, :notification => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested notification" do
        Notification.should_receive(:get).with("37") { mock_notification }
        mock_notification.should_receive(:update).with({'these' => 'params'})
        put :update, :id => "37", :notification => {'these' => 'params'}
      end

      it "assigns the requested notification as @notification" do
        Notification.stub(:get) { mock_notification(:update => true) }
        put :update, :id => "1"
        assigns(:notification).should be(mock_notification)
      end

      it "redirects to the notification" do
        Notification.stub(:get) { mock_notification(:update => true) }
        put :update, :id => "1"
        response.should redirect_to(notification_url(mock_notification))
      end
    end

    describe "with invalid params" do
      it "assigns the notification as @notification" do
        Notification.stub(:get) { mock_notification(:update => false) }
        put :update, :id => "1"
        assigns(:notification).should be(mock_notification)
      end

      it "re-renders the 'edit' template" do
        Notification.stub(:get) { mock_notification(:update => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested notification" do
      Notification.should_receive(:get).with("37") { mock_notification }
      mock_notification.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the notifications list" do
      Notification.stub(:get) { mock_notification }
      delete :destroy, :id => "1"
      response.should redirect_to(notifications_url)
    end
  end

end
