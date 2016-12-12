require 'test_helper'

class SettingsHelperTest < ActionView::TestCase

  include SettingsHelper

  def setup
    @setting = settings(:application_name)
  end

  test 'setting_value should return input string if the setting name is not valid' do
    assert setting_value('i_can_haz_setting') == 'i_can_haz_setting'
  end

  test 'setting_value should return default value if the setting is not present' do
    setting_name = @setting.name
    @setting.destroy
    assert setting_value(setting_name) == default_setting_value(setting_name)
  end

  test 'setting_value should retrun default value if the setting value is empty' do
    # make sure setting value is empty
    @setting.update_attributes(value: '')
    assert setting_value(@setting.name) == default_setting_value(@setting.name)
  end

  test 'setting_value should return the setting value' do
    @setting.update_attributes(value: 'wow, a setting value!')
    assert setting_value(@setting.name) == 'wow, a setting value!'
  end
end