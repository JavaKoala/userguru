require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @admin_user = users(:admin_user)
    @customer1  = users(:customer1)
    @customer2  = users(:customer2)
    add_roles_to_users
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "should redirect get when not logged in" do
    get user_path(@customer1)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when not logged in" do
    get edit_user_path(@customer1)
    assert_not flash.empty?
    assert_redirected_to login_url
  end
  
  test "should redirect update when not logged in" do
    patch user_path(@customer1), params: { user: { name: @customer1.name, email: @customer1.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when logged in as wrong user" do
    log_in_as(@customer2)
    get edit_user_path(@customer1)
    assert_redirected_to login_url
  end
  
  test "should redirect update when logged in as wrong user" do
    log_in_as(@customer2)
    patch user_path(@customer1), params: { user: { name: @customer1.name, email: @customer1.email } }
    assert_redirected_to login_url
  end

  test "should redirect show when logged in with customer role" do
    log_in_as(@customer1)
    get user_path(@customer2)
    assert_redirected_to login_url
  end

  test "should not redirect show with an admin user" do
    log_in_as(@admin_user)
    get user_path(@customer2)
    assert_response :success
  end
end
