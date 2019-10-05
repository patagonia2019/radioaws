require 'test_helper'

class ArchivecatalogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @archivecatalog = archivecatalogs(:one)
  end

  test "should get index" do
    get archivecatalogs_url
    assert_response :success
  end

  test "should get new" do
    get new_archivecatalog_url
    assert_response :success
  end

  test "should create archivecatalog" do
    assert_difference('Archivecatalog.count') do
      post archivecatalogs_url, params: { archivecatalog: { detail: @archivecatalog.detail, identifier: @archivecatalog.identifier, subtitle: @archivecatalog.subtitle, title: @archivecatalog.title } }
    end

    assert_redirected_to archivecatalog_url(Archivecatalog.last)
  end

  test "should show archivecatalog" do
    get archivecatalog_url(@archivecatalog)
    assert_response :success
  end

  test "should get edit" do
    get edit_archivecatalog_url(@archivecatalog)
    assert_response :success
  end

  test "should update archivecatalog" do
    patch archivecatalog_url(@archivecatalog), params: { archivecatalog: { detail: @archivecatalog.detail, identifier: @archivecatalog.identifier, subtitle: @archivecatalog.subtitle, title: @archivecatalog.title } }
    assert_redirected_to archivecatalog_url(@archivecatalog)
  end

  test "should destroy archivecatalog" do
    assert_difference('Archivecatalog.count', -1) do
      delete archivecatalog_url(@archivecatalog)
    end

    assert_redirected_to archivecatalogs_url
  end
end
