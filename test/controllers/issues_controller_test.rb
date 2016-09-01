require 'test_helper'

class IssuesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user  = users(:one)
    @user.roles << Role.where(name: 'customer')
    @other_user = users(:two)
    @other_user.roles << Role.where(name: 'representative')
    @issue = issues(:one)
  end
  
  test "should redirect when not logged in" do
    get new_issue_path
    assert_redirected_to login_url
  end

  test "should create new issue" do
    log_in_as(@user)
    get new_issue_path
    assert_difference 'Issue.count', 1 do
      post issues_path, params: { issue: { title: "test title", 
                                           description: "test description", 
                                           user_id: @user.id } }
      follow_redirect!
    end
    assert_response :success
  end
  
  test "should not create issue when there is no title" do
    log_in_as(@user)
    get new_issue_path
    assert_no_difference 'Issue.count' do
      post issues_path, params: { issue: { title: "", 
                                           description: "test description", 
                                           user_id: @user.id } }
    end
  end
  
  test "should not create issue when there is no description" do
    log_in_as(@user)
    get new_issue_path
    assert_no_difference 'Issue.count' do
      post issues_path, params: { issue: { title: "test title", 
                                           description: "", 
                                           user_id: @user.id } }
    end
  end
  
  test "should not create issue when there is no user id" do
    log_in_as(@user)
    get new_issue_path
    assert_no_difference 'Issue.count' do
      post issues_path, params: { issue: { title: "test title", 
                                           description: "test desciption", 
                                           user_id: "" } }
    end
  end

  test "should redirect show when not logged in" do
    get issue_path(@issue)
    assert_redirected_to login_url
  end

  test "should redirect edit when not logged in" do
    get edit_issue_path(@issue)
    assert_redirected_to login_url
  end
  
  test "should edit issue" do
    log_in_as(@user)
    get edit_issue_path(@issue)
    patch issue_path(@issue), params: { issue: { title: "new title",
                                                 description: "new description" } }
    assert_redirected_to issue_path(@issue)
    assert @issue.title = "new title"
    assert @issue.description = "new description"
  end

end
