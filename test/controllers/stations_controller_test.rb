require 'test_helper'

class StationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @station = stations(:one)
  end

  test "should get index" do
    get stations_url
    assert_response :success
  end

  test "should get new" do
    get new_station_url
    assert_response :success
  end

  test "should create station" do
    assert_difference('Station.count') do
      post stations_url, params: { station: { city_id: @station.city_id, country_id: @station.country_id, district_id: @station.district_id, hash: @station.hash, imageUrl: @station.imageUrl, is_am: @station.is_am, land_id: @station.land_id, name: @station.name, tuning_dial: @station.tuning_dial } }
    end

    assert_redirected_to station_url(Station.last)
  end

  test "should show station" do
    get station_url(@station)
    assert_response :success
  end

  test "should get edit" do
    get edit_station_url(@station)
    assert_response :success
  end

  test "should update station" do
    patch station_url(@station), params: { station: { city_id: @station.city_id, country_id: @station.country_id, district_id: @station.district_id, hash: @station.hash, imageUrl: @station.imageUrl, is_am: @station.is_am, land_id: @station.land_id, name: @station.name, tuning_dial: @station.tuning_dial } }
    assert_redirected_to station_url(@station)
  end

  test "should destroy station" do
    assert_difference('Station.count', -1) do
      delete station_url(@station)
    end

    assert_redirected_to stations_url
  end
end
