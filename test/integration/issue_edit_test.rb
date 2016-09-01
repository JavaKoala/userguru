require 'test_helper'

class IssueEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:one)
    @user.roles << Role.where(name: 'customer')
  end
  
  test "issue edit test" do
    log_in_as(@user)
    get new_issue_path
    post issues_path, params: { issue: { title: "test title", 
                                         description: "test description", 
                                         user_id: @user.id } }
    follow_redirect!
    assert_response :success
    assert_select "a[href=?]", edit_issue_path, count: 1
    assert_select "li", /test title/
    assert_select "li", /test description/
    assert_select "li", /Open/
    @issue = Issue.find_by( title: "test title" )
    get edit_issue_path(@issue)
    patch issue_path(@issue), params: { issue: { title: "updated title",
                                                 description: "updated description",
                                                 status: :closed,
                                                 user_id: @user.id } }
    follow_redirect!
    assert_response :success
    assert_select "a[href=?]", edit_issue_path, count: 1
    assert_select "li", /updated title/
    assert_select "li", /updated description/
    assert_select "li", /Closed/
  end 
end
