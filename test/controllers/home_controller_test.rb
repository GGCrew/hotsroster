require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get about" do
    get :about
    assert_response :success
  end

  test "should get copyrights" do
    get :copyrights
    assert_response :success
  end

  test "should get sitemap.xml" do
    get :sitemap, format: :xml
    assert_response :success
    assert_raises(Exception) { get :sitemap }
  end

  test "should get robots.txt" do
    get :robots, format: :txt
    assert_response :success
    assert_raises(Exception) { get :robots }
  end
end
