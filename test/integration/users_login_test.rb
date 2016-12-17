require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  include SessionsHelper

  def setup
    @customer1 = users(:customer1)
    add_roles_to_users
  end
  
  test "login with invalid information followed by logout" do
    get login_path
    assert_response :success
    post login_path, params: { session: { email: @customer1.email,
                                          password: 'password' } }
    assert is_logged_in?
    assert_not internal_user?
    assert_redirected_to @customer1
    follow_redirect!
    assert_response :success
    assert @users.nil?
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", issues_path, count: 0
    assert_select "a[href=?]", user_path(@customer1)
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@customer1), count: 0
  end
  
  test "login with remembering" do
    log_in_as(@customer1, remember_me: '1')
    assert_not_nil cookies['remember_token']
  end
  
  test "login without remembering" do
    log_in_as(@customer1, remember_me: '0')
    assert_nil cookies['remember_token']
  end
end
