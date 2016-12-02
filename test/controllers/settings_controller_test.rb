require 'test_helper'

class SettingsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @setting = settings(:one)
  end

  test 'setting update should work' do
    get settings_path
    patch setting_path(@setting), params: { setting: { value: "updated setting" } } 
    assert_redirected_to settings_path
    assert_not flash.empty?
    @setting.reload
    assert @setting.value == "updated setting"
  end

  test 'settings update should not work if there is no value' do
    get settings_path
    assert_raises ("ParameterMissing") {
      patch setting_path(@setting), params: { setting: nil }
    }
  end

  test 'settings update should not work if there is no setting' do
    get settings_path
    @setting.id = 8675309
    assert_raises ("RecordNotFound") {
      patch setting_path(@setting), params: { setting: { value: "updated setting" } }
    }
  end
end
