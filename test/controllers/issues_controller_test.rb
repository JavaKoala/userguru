require 'test_helper'

class IssuesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user  = users(:one)
    @user.roles << Role.where(name: 'customer')
    @other_user = users(:two)
    @other_user.roles << Role.where(name: 'representative')
    @issue = issues(:one)
    @issue.user_issue = UserIssue.new
    @other_issue = issues(:two)
    @other_issue.user_issue = UserIssue.new
  end
  
  test "should redirect when not logged in" do
    get new_issue_path
    assert_redirected_to login_url
  end

  test "show should only display for a logged in user" do
    get issue_path(@issue)
    assert_redirected_to login_url
  end

  test "show should only display for an internal or correct user" do
    log_in_as(@user)
    get issue_path(@issue)
    assert_response :success
    get issue_path(@other_issue)
    assert_redirected_to root_url
    @user.roles << Role.where(name: 'admin')
    get issue_path(@other_issue)
    assert_response :success
  end

  test "should not display index unless logged in" do
    get issues_path
    assert_redirected_to login_url
  end

  test "should display index for an internal user" do
    log_in_as(@other_user)
    get issues_path
    assert_response :success
  end

  test "should create new issue" do
    log_in_as(@user)
    get new_issue_path
    assert_difference 'Issue.count', 1 do
      # the new issue should also create a new UserIssue
      assert_difference 'UserIssue.count', 1 do
        post issues_path, params: { issue: { title: "test title", 
                                             description: "test description", 
                                             user_id: @user.id } }
        follow_redirect!
      end
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

  test "should redirect edit when not the issue creator or an internal user" do
    log_in_as(@user)
    get edit_issue_path(@other_issue)
    assert_redirected_to root_url
    @user.roles << Role.where(name: 'admin')
    get edit_issue_path(@other_issue)
    assert_response :success
  end

  test "issues show should include comments and new comments" do
    log_in_as(@user)
    get new_issue_path
    post issues_path, params: { issue: { title: "test title", 
                                         description: "test description", 
                                         user_id: @user.id } }
    follow_redirect!
    assert_response :success
    @issue = Issue.find_by(title: "test title")
    get issue_path(@issue)
    assert_response :success
    post comments_path, params: { comment: { text: "comment title" },
                                             issue_id: @issue.id }
    follow_redirect!
    assert_select "li", /comment title/
  end
  
  test "should edit issue" do
    log_in_as(@user)
    get new_issue_path
    post issues_path, params: { issue: { title: "test title", 
                                         description: "test description", 
                                         user_id: @user.id } }
    follow_redirect!
    assert_response :success
    @issue = Issue.find_by(title: "test title")
    get edit_issue_path(@issue)
    patch issue_path(@issue), params: { issue: { title: "new title",
                                                 description: "new description" } }
    assert_redirected_to issue_path(@issue)
    assert @issue.title = "new title"
    assert @issue.description = "new description"
    # Test for assigned user
    @user.roles << Role.where(name: 'representative')
    get edit_issue_path(@issue)
    patch issue_path(@issue), params: { issue: { title: "new title",
                                                 description: "new description" }, 
                                        user_issue: { assigned_user: @user.id } }
    assert_redirected_to issue_path(@issue)
    assert @issue.user_issue.user_id = @user.id
  end

  test "should redirect delete when not logged in" do
    assert_no_difference 'Issue.count' do
      delete issue_url(@issue)
    end
    assert_redirected_to login_url
  end
  
  test "should delete issue" do
    @other_user.roles << Role.where(name: 'admin')
    log_in_as(@other_user)
    assert_difference 'Issue.count', -1 do
      delete issue_url(@issue)
    end
    assert_redirected_to users_url
  end
  
  test "should redirect delete when logged in as non-admin" do
    log_in_as(@other_user)
    assert_no_difference 'Issue.count' do
      delete issue_url(@issue)
    end
    assert_redirected_to login_url
  end
end
