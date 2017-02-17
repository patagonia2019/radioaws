require 'test_helper'

class LandsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @land = lands(:one)
  end

  test "should get index" do
    get lands_url
    assert_response :success
  end

  test "should get new" do
    get new_land_url
    assert_response :success
  end

  test "should create land" do
    assert_difference('Land.count') do
      post lands_url, params: { land: { name: @land.name } }
    end

    assert_redirected_to land_url(Land.last)
  end

  test "should show land" do
    get land_url(@land)
    assert_response :success
  end

  test "should get edit" do
    get edit_land_url(@land)
    assert_response :success
  end

  test "should update land" do
    patch land_url(@land), params: { land: { name: @land.name } }
    assert_redirected_to land_url(@land)
  end

  test "should destroy land" do
    assert_difference('Land.count', -1) do
      delete land_url(@land)
    end

    assert_redirected_to lands_url
  end
end
