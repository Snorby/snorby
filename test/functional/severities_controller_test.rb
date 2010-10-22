require 'test_helper'

class SeveritiesControllerTest < ActionController::TestCase
  setup do
    @severity = severities(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:severities)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create severity" do
    assert_difference('Severity.count') do
      post :create, :severity => @severity.attributes
    end

    assert_redirected_to severity_path(assigns(:severity))
  end

  test "should show severity" do
    get :show, :id => @severity.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @severity.to_param
    assert_response :success
  end

  test "should update severity" do
    put :update, :id => @severity.to_param, :severity => @severity.attributes
    assert_redirected_to severity_path(assigns(:severity))
  end

  test "should destroy severity" do
    assert_difference('Severity.count', -1) do
      delete :destroy, :id => @severity.to_param
    end

    assert_redirected_to severities_path
  end
end
