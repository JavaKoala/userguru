require 'test_helper'

class SettingTest < ActiveSupport::TestCase

  test "setting name should be present" do
    @setting = Setting.first
    @setting.name = nil
    assert_not @setting.valid?
  end
end
