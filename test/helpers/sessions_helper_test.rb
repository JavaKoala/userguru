require 'test_helper'

class SessionsHelperTest < ActionView::TestCase

  include SessionsHelper

  def setup
    @user = users(:one)
    @user.roles << Role.where(name: 'customer')
    remember(@user)
  end
  
  test "current_user returns right user when session is nil" do
    assert_equal @user, current_user
    assert is_logged_in?
  end

  test "current_user returns nil when remember digest is wrong" do
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
  end
  
  test "current user should not be internal if they only have the customer role" do
    assert_not internal_user?
  end
  
  test "current user should not be admin if they do not have the admin role" do
    @user.roles << Role.where(name: 'representative')
    assert_not admin_user?
  end

  test "current user should be internal and admin if they have the admin role" do
    @user.roles << Role.where(name: 'admin')
    assert internal_user?
    assert admin_user?
  end

  test "current user should be internal if they have the representative role" do
    @user.roles << Role.where(name: 'representative')
    assert internal_user?
  end
end