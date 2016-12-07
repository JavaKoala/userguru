require 'test_helper'

class SettingTest < ActiveSupport::TestCase

  test "setting name should be present" do
    @setting = Setting.first
    @setting.name = nil
    assert_not @setting.valid?
  end

  test "default_email should be blank or an email address" do
    # The default email setting is the fourth setting
    @setting = Setting.fourth
    assert @setting.name = "default_email"
    @setting.value = "I can haz email"
    assert_not @setting.valid?
    @setting.value = ""
    assert @setting.valid?
    @setting.value = "test@test"
    assert_not @setting.valid?
    @setting.value = "@test.com"
    assert_not @setting.valid?
  end
end
