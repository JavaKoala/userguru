require 'test_helper'

class SessionsHelperTest < ActionView::TestCase

  include SessionsHelper

  def setup
    @admin_user          = users(:admin_user)
    @customer1           = users(:customer1)
    @representative_user = users(:representative)
    add_roles_to_users
    remember(@customer1)
  end
  
  test "current_user returns right user when session is nil" do
    assert_equal @customer1, current_user
    assert is_logged_in?
  end

  test "current_user returns nil when remember digest is wrong" do
    @customer1.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
  end
  
  test "current user should not be internal if they only have the customer role" do
    log_in_as(@customer1)
    assert_not internal_user?
  end

  test "current user should not be admin if they do not have the admin role" do
    log_in_as(@representative_user)
    assert_not admin_user?
  end

  test "current user should be internal and admin if they have the admin role" do
    log_in_as(@admin_user)
    assert internal_user?
    assert admin_user?
  end

  test "current user should be internal if they have the representative role" do
    log_in_as(@representative_user)
    assert internal_user?
  end

  test "the user has to be logged in to be internal or admin" do
    log_out
    assert_not internal_user?
    assert_not admin_user?
  end
end