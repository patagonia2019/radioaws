require 'test_helper'

class ArchiveOrgAudiosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @archive_org_audio = archive_org_audios(:one)
  end

  test "should get index" do
    get archive_org_audios_url
    assert_response :success
  end

  test "should get new" do
    get new_archive_org_audio_url
    assert_response :success
  end

  test "should create archive_org_audio" do
    assert_difference('ArchiveOrgAudio.count') do
      post archive_org_audios_url, params: { archive_org_audio: { detail: @archive_org_audio.detail, identifier: @archive_org_audio.identifier, subtitle: @archive_org_audio.subtitle, title: @archive_org_audio.title } }
    end

    assert_redirected_to archive_org_audio_url(ArchiveOrgAudio.last)
  end

  test "should show archive_org_audio" do
    get archive_org_audio_url(@archive_org_audio)
    assert_response :success
  end

  test "should get edit" do
    get edit_archive_org_audio_url(@archive_org_audio)
    assert_response :success
  end

  test "should update archive_org_audio" do
    patch archive_org_audio_url(@archive_org_audio), params: { archive_org_audio: { detail: @archive_org_audio.detail, identifier: @archive_org_audio.identifier, subtitle: @archive_org_audio.subtitle, title: @archive_org_audio.title } }
    assert_redirected_to archive_org_audio_url(@archive_org_audio)
  end

  test "should destroy archive_org_audio" do
    assert_difference('ArchiveOrgAudio.count', -1) do
      delete archive_org_audio_url(@archive_org_audio)
    end

    assert_redirected_to archive_org_audios_url
  end
end
