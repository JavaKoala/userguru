require 'test_helper'

class IssuesControllerTest < ActionDispatch::IntegrationTest

  def setup
    # Setup users
    @admin_user          = users(:admin_user)
    @representative_user = users(:representative)
    @customer1           = users(:customer1)
    add_roles_to_users

    # Setup issues
    @customer1_issue     = issues(:customer1_issue)
    @customer2_issue     = issues(:customer2_issue)
    add_user_issue
  end
  
  test "should redirect when not logged in" do
    get new_issue_path
    assert_redirected_to login_url
  end

  test "show should only display for a logged in user" do
    get issue_path(@customer1_issue)
    assert_redirected_to login_url
  end

  test "show should only display correct issue for customer" do
    log_in_as(@customer1)
    get issue_path(@customer1_issue)
    assert_response :success
    get issue_path(@customer2_issue)
    assert_redirected_to root_url
  end

  test "show should should always display for an internal user" do
    log_in_as(@representative_user)
    get issue_path(@customer2_issue)
    assert_response :success
  end

  test "should not display index unless logged in" do
    get issues_path
    assert_redirected_to login_url
  end

  test "should display index for an internal user" do
    log_in_as(@customer1)
    get issues_path
    assert_response :success
  end

  test "should create new issue" do
    log_in_as(@customer1)
    get new_issue_path
    assert_difference 'Issue.count', 1 do
      # the new issue should also create a new UserIssue
      assert_difference 'UserIssue.count', 1 do
        post issues_path, params: { issue: { title: "test title", 
                                             description: "test description", 
                                             user_id: @customer1.id } }
        follow_redirect!
      end
    end
    assert_response :success
  end
  
  test "should not create issue when there is no title" do
    log_in_as(@customer1)
    get new_issue_path
    assert_no_difference 'Issue.count' do
      post issues_path, params: { issue: { title: "", 
                                           description: "test description", 
                                           user_id: @customer1.id } }
    end
  end
  
  test "should not create issue when there is no description" do
    log_in_as(@customer1)
    get new_issue_path
    assert_no_difference 'Issue.count' do
      post issues_path, params: { issue: { title: "test title", 
                                           description: "", 
                                           user_id: @customer1.id } }
    end
  end
  
  test "should not create issue when there is no user id" do
    log_in_as(@customer1)
    get new_issue_path
    assert_no_difference 'Issue.count' do
      post issues_path, params: { issue: { title: "test title", 
                                           description: "test desciption", 
                                           user_id: "" } }
    end
  end

  test "should redirect show when not logged in" do
    get issue_path(@customer1_issue)
    assert_redirected_to login_url
  end

  test "should redirect edit when not logged in" do
    get edit_issue_path(@customer1_issue)
    assert_redirected_to login_url
  end

  test "should redirect edit when not the issue creator or an internal user" do
    log_in_as(@customer1)
    get edit_issue_path(@customer2_issue)
    assert_redirected_to root_url
  end

  test "should not redirect edit when the issue creator" do
    log_in_as(@customer1)
    get edit_issue_path(@customer1_issue)
    assert_response :success
  end

  test "should not redirect edit when an internal user" do
    log_in_as(@representative_user)
    get edit_issue_path(@customer1_issue)
    assert_response :success
  end

  test "issues show should include comments and new comments" do
    log_in_as(@customer1)
    get new_issue_path
    post issues_path, params: { issue: { title: "test title", 
                                         description: "test description", 
                                         user_id: @customer1.id } }
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
    log_in_as(@customer1)
    get new_issue_path
    post issues_path, params: { issue: { title: "test title", 
                                         description: "test description", 
                                         user_id: @customer1.id } }
    follow_redirect!
    assert_response :success
    @issue = Issue.find_by(title: "test title")
    get edit_issue_path(@issue)
    patch issue_path(@issue), params: { issue: { title: "new title",
                                                 description: "new description" } }
    assert_redirected_to issue_path(@issue)
    assert @issue.title = "new title"
    assert @issue.description = "new description"
    delete logout_path
    assert_not is_logged_in?
    # Test for assigned user
    log_in_as(@representative_user)
    get edit_issue_path(@issue)
    patch issue_path(@issue), params: { issue: { title: "new title",
                                                 description: "new description" }, 
                                        user_issue: { assigned_user: @representative_user.id } }
    assert_redirected_to issue_path(@issue)
    assert @issue.user_issue.user_id = @representative_user.id
  end

  test "should redirect delete when not logged in" do
    assert_no_difference 'Issue.count' do
      delete issue_url(@customer1_issue)
    end
    assert_redirected_to login_url
  end
  
  test "should delete issue" do
    log_in_as(@admin_user)
    assert_difference 'Issue.count', -1 do
      delete issue_url(@customer1_issue)
    end
    assert_redirected_to users_url
  end
  
  test "should redirect delete when logged in as non-admin" do
    log_in_as(@representative_user)
    assert_no_difference 'Issue.count' do
      delete issue_url(@customer1_issue)
    end
    assert_redirected_to login_url
  end
end
