require 'test_helper'

class IssueEditTest < ActionDispatch::IntegrationTest

  def setup
    @representative_user = users(:representative)
    @customer1           = users(:customer1)
    add_roles_to_users
  end

  test "issue edit test" do
    log_in_as(@representative_user)
    get new_issue_path
    post issues_path, params: { issue: { title: "test title", 
                                         description: "test description", 
                                         user_id: @representative_user.id } }
    follow_redirect!
    assert_response :success
    @issue = Issue.find_by( title: "test title" )
    assert_select "a[href=?]", edit_issue_path(@issue), count: 1
    assert_select "td", /test title/
    assert_select "td", /Open/
    get edit_issue_path(@issue)
    patch issue_path(@issue), params: { issue: { title: "updated title",
                                                 description: "updated description",
                                                 status: :closed,
                                                 user_id: @representative_user.id },
                                        user_issue: { assigned_user: @representative_user.id} }
    follow_redirect!
    assert_response :success
    assert_select "a[href=?]", edit_issue_path, count: 1
    assert_select "h1", /updated title/
    assert_select "li", /updated description/
    assert_select "li", /Closed/
    assert_select "li", /Assigned to: #{@representative_user.name}/
  end
  
  test "customers cannot edit the status and assigned user of issues" do
    log_in_as(@customer1)
    get new_issue_path
    post issues_path, params: { issue: { title: "test title", 
                                         description: "test description", 
                                         user_id: @customer1.id } }
    follow_redirect!
    assert_response :success
    @issue = Issue.find_by( title: "test title" )
    get edit_issue_path(@issue)
    assert_select "option", false
  end
  
  test "unsuccessful edit, title and description empty" do
    log_in_as(@customer1)
    get new_issue_path
    post issues_path, params: { issue: { title: "test title", 
                                         description: "test description", 
                                         user_id: @customer1.id } }
    follow_redirect!
    assert_response :success
    @issue = Issue.find_by( title: "test title" )
    get edit_issue_path(@issue)
    patch issue_path(@issue), params: { issue: { title: '',
                                                 description: '' } }
    assert_response :success
    assert @issue.title = "test title"
    assert @issue.title = "test description"
  end
end
