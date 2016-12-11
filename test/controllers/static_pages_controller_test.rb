require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @representative_user = users(:representative)
    add_roles_to_users
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
    log_in_as(@representative_user)
    follow_redirect!
    assert_response :success
    assert @static_pages.nil?
  end
end
