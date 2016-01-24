require 'test_helper'

class RotationsControllerTest < ActionController::TestCase
  setup do
    @rotation = date_ranges(:date_range_1)
  end

	test 'should get index' do
		get :index
		assert_response :success
	end

	test 'should get show' do
		rotations = DateRange.all
		rotations.each do |rotation|
			get :show, id: rotation
			assert_response :success
		end
	end

  test "should not get new" do
    assert_raises(Exception) { get :new }
  end

  test "should not create rotation" do
    assert_raises(Exception) { post :create, rotation: {  } }
  end

  test "should not get edit" do
    assert_raises(Exception) { get :edit, id: @rotation }
  end

  test "should not update rotation" do
    assert_raises(Exception) { patch :update, id: @rotation, rotation: {  } }
  end

  test "should not destroy rotation" do
    assert_raises(Exception) { delete :destroy, id: @rotation }
  end
end
