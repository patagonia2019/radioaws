require 'test_helper'

class DesconciertosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @desconcierto = desconciertos(:one)
  end

  test "should get index" do
    get desconciertos_url
    assert_response :success
  end

  test "should get new" do
    get new_desconcierto_url
    assert_response :success
  end

  test "should create desconcierto" do
    assert_difference('Desconcierto.count') do
      post desconciertos_url, params: { desconcierto: { at_date: @desconcierto.at_date, url1: @desconcierto.url1, url2: @desconcierto.url2, url3: @desconcierto.url3 } }
    end

    assert_redirected_to desconcierto_url(Desconcierto.last)
  end

  test "should show desconcierto" do
    get desconcierto_url(@desconcierto)
    assert_response :success
  end

  test "should get edit" do
    get edit_desconcierto_url(@desconcierto)
    assert_response :success
  end

  test "should update desconcierto" do
    patch desconcierto_url(@desconcierto), params: { desconcierto: { at_date: @desconcierto.at_date, url1: @desconcierto.url1, url2: @desconcierto.url2, url3: @desconcierto.url3 } }
    assert_redirected_to desconcierto_url(@desconcierto)
  end

  test "should destroy desconcierto" do
    assert_difference('Desconcierto.count', -1) do
      delete desconcierto_url(@desconcierto)
    end

    assert_redirected_to desconciertos_url
  end
end
