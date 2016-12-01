require 'test_helper'

class SettingsHelperTest < ActionView::TestCase

  include SettingsHelper

  def setup
    @setting = settings(:one)
  end

  test 'setting_value should return input string if the setting name is not present' do
    assert setting_value('i_can_haz_setting') == 'i_can_haz_setting'
  end

  test 'setting_value should retrun default value if the setting value is empty' do
    assert setting_value(@setting.name) == default_setting_value(@setting.name)
  end

  test 'setting_value should return the setting value' do
    @setting.update_attributes(value: 'wow, a setting value!')
    assert setting_value(@setting.name) == 'wow, a setting value!'
  end
end