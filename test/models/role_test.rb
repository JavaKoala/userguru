require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  
  def setup
    @role = Role.new(name: "admin")
  end
  
  test "role should be valid" do
    assert @role.valid?
  end
end
