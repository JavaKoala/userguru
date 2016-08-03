require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  include SessionsHelper

  def setup
    @user = users(:one)
    @user.roles << Role.where(name: 'customer')
  end
  
  test "login with invalid information followed by logout" do
    get login_path
    assert_response :success
    post login_path, params: { session: { email: @user.email,
                                          password: 'password' } }
    assert is_logged_in?
    assert_not internal_user?
    assert_redirected_to @user
    follow_redirect!
    assert_response :success
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end
  
  test "login with remembering" do
    log_in_as(@user, remember_me: '1')
    assert_not_nil cookies['remember_token']
  end
  
  test "login without remembering" do
    log_in_as(@user, remember_me: '0')
    assert_nil cookies['remember_token']
  end
end
