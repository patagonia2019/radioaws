require 'test_helper'

class TheftsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @theft = thefts(:one)
  end

  test "should get index" do
    get thefts_url
    assert_response :success
  end

  test "should get new" do
    get new_theft_url
    assert_response :success
  end

  test "should create theft" do
    assert_difference('Theft.count') do
      post thefts_url, params: { theft: { url: @theft.url } }
    end

    assert_redirected_to theft_url(Theft.last)
  end

  test "should show theft" do
    get theft_url(@theft)
    assert_response :success
  end

  test "should get edit" do
    get edit_theft_url(@theft)
    assert_response :success
  end

  test "should update theft" do
    patch theft_url(@theft), params: { theft: { url: @theft.url } }
    assert_redirected_to theft_url(@theft)
  end

  test "should destroy theft" do
    assert_difference('Theft.count', -1) do
      delete theft_url(@theft)
    end

    assert_redirected_to thefts_url
  end
end
