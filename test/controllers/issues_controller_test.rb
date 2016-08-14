require 'test_helper'

class IssuesControllerTest < ActionDispatch::IntegrationTest

  def setup
    # @user  = user(:one)
    # @user.roles << Role.where(name: 'customer')
    @issue = issues(:one)
  end
  
  test "should redirect when not logged in" do
    get new_issue_path
    assert_redirected_to login_url
  end

  test "should create new issue" do
    # get new_issue_path
  end

end
