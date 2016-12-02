require 'test_helper'

class SettingsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user  = users(:one)
    @user.roles << Role.where(name: 'admin')
    @other_user = users(:two)
    @other_user.roles << Role.where(name: 'customer')
    @other_user.roles << Role.where(name: 'representative')
    @setting = settings(:one)
  end

  test 'should not be able to access settings index unless logged in' do
    get settings_path
    assert_redirected_to login_url
  end

  test 'should not be able to update settings index unless logged in' do
    setting_value = @setting.value
    patch setting_path(@setting), params: { setting: { value: "updated setting" } }
    assert_redirected_to login_url
    @setting.reload
    assert @setting.value = setting_value
  end

  test 'should not be able to access settings index if not admin user' do
    log_in_as(@other_user)
    get settings_path
    assert_redirected_to login_url
  end

  test 'should not be able to update settings if not admin user' do
    setting_value = @setting.value
    log_in_as(@other_user)
    get settings_path
    patch setting_path(@setting), params: { setting: { value: "updated setting" } }
    assert_redirected_to login_url
    @setting.reload
    assert @setting.value = setting_value
  end

  test 'setting update should work' do
    log_in_as(@user)
    get settings_path
    patch setting_path(@setting), params: { setting: { value: "updated setting" } }
    assert_redirected_to settings_path
    assert_not flash.empty?
    @setting.reload
    assert @setting.value == "updated setting"
  end

  test 'settings update should not work if there is no value' do
    log_in_as(@user)
    get settings_path
    assert_raises ("ParameterMissing") {
      patch setting_path(@setting), params: { setting: nil }
    }
  end

  test 'settings update should not work if there is no setting' do
    log_in_as(@user)
    get settings_path
    @setting.id = 8675309
    assert_raises ("RecordNotFound") {
      patch setting_path(@setting), params: { setting: { value: "updated setting" } }
    }
  end
end
