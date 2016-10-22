require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:one)
    @user.roles << Role.where(name: 'customer')
    @other_user = users(:two)
    @other_user.roles << Role.where(name: 'customer')
    @other_issue = issues(:two)
    @other_issue.user_issue = UserIssue.new
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "should redirect get when not logged in" do
    get user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end
  
  test "should redirect update when not logged in" do
    patch user_path(@user), params: { user: { name: @user.name, email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert_redirected_to login_url
  end
  
  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name, email: @user.email } }
    assert_redirected_to login_url
  end

  test "should redirect show when logged in with customer role" do
    log_in_as(@user)
    get user_path(@other_user)
    assert_redirected_to login_url
  end

  test "should not redirect show with an admin user" do
    @user.roles << Role.where(name: 'admin')
    log_in_as(@user)
    get user_path(@other_user)
    assert_response :success
  end
end
