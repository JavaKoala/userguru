require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  
  def setup
    @role = Role.new(name: "admin")
  end
  
  test "role should be valid" do
    assert @role.valid?
  end
  
  test "role name should not be blank" do
    @role.name = "     "
    assert_not @role.valid?
  end
  
  test "role name should be at least 4 characters" do
    @role.name = "lol"
    assert_not @role.valid?
  end
end
