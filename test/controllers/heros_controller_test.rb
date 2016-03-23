require 'test_helper'

class HerosControllerTest < ActionController::TestCase
  setup do
    @hero = heros(:hero_1)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:heros)
  end

  test "should not get new" do
    assert_raises(Exception) { get :new }
  end

  test "should not create hero" do
    assert_raises(Exception) { post :create, hero: {  } }
  end

  test "should show hero" do
  	heroes = Hero.all
  	heroes.each do |hero|
	    get :show, id: hero
	    assert_response :success
	  end
  end

  test "should not get edit" do
    assert_raises(Exception) { get :edit, id: @hero }
  end

  test "should not update hero" do
    assert_raises(Exception) { patch :update, id: @hero, hero: {  } }
  end

  test "should not destroy hero" do
    assert_raises(Exception) { delete :destroy, id: @hero }
  end
end
