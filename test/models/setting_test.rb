require 'test_helper'

class SettingTest < ActiveSupport::TestCase
  
  def setup
    @setting = settings(:one)
  end

  test "setting name should be present" do
    @setting.name = nil
    assert_not @setting.valid?
  end
end
