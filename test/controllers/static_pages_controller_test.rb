require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:one)
    @user.roles << Role.where(name: 'representative')
    @issue = issues(:one)
    @issue.user_issue = UserIssue.new
  end

  test "should get help" do
    get help_path
    assert_response :success
  end

  test "should get about" do
    get about_path
    assert_response :success
  end

  test "root should get home" do
    get root_url
    assert_response :success
  end
  
  test "layout links test" do
    get root_path
    assert_response :success
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", signup_path
  end

  test "@static_pages should be empty" do
    log_in_as(@user)
    follow_redirect!
    assert_response :success
    assert @static_pages.nil?
  end
end
