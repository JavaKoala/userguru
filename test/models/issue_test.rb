require 'test_helper'

class IssueTest < ActiveSupport::TestCase
  
  def setup
    @user = users(:one)
    @other_user = users(:two)
    @issue = issues(:one)
    @user_issue = UserIssue.new(issue_id: @issue.id, user_id: @other_user.id)
    @other_issue = issues(:two)
    @other_issue.user_issue = UserIssue.new
  end
  
  test "issue should be valid" do
    assert @issue.valid?
  end
  
  test "user ID should be present" do
    @issue.user_id = nil
    assert_not @issue.valid?
  end
  
  test "title should be present" do
    @issue.title = nil
    assert_not @issue.valid?
  end
  
  test "title should not be too long" do
    @issue.title = "a" * 101
    assert_not @issue.valid?
  end
  
  test "description should be present" do
    @issue.description = nil
    assert_not @issue.valid?
  end
  
  test "description should not be too long" do
    @issue.description = "a" * 256
    assert_not @issue.valid?
  end

  test "user_assigned_issues should return all the issues if assigned_user_id is nil" do
    assert Issue.user_assigned_issues(nil) == Issue.all
  end

  test "find_title_or_description should return all the issues if search is nil" do
    assert Issue.find_title_or_description(nil) == Issue.all
  end

  test "find_issues_with_status should return all the issues if the status is nil" do
    assert Issue.find_issues_with_status(nil) == Issue.all
  end

  test "find_issues_created_by_user should return all the issues if the status is nil" do
    assert Issue.find_issues_created_by_user(nil) == Issue.all
  end

  test "search should retun unassigned issues if search is nil" do
    issue_search_params = { search: "", status: "", assigned_user_id: "", creator_user_id: "" }
    issue_search = { search_params: issue_search_params }
    assert Issue.search(issue_search) == Issue.all
  end

  test "search should look in title" do
    issue_search_params = { search: "first", status: "", assigned_user_id: "", creator_user_id: "" }
    issue_search = { search_params: issue_search_params }
    assert Issue.search(issue_search)[0] == @issue
  end

  test "search should look in description" do
    issue_search_params = { search: "LOL", status: "", assigned_user_id: "", creator_user_id: "" }
    issue_search = { search_params: issue_search_params }
    assert Issue.search(issue_search)[0] == @issue
  end

  test "search should find status" do
    issue_search_params = { search: "", status:  @other_issue.status, assigned_user_id: "", creator_user_id: "" }
    issue_search = { search_params: issue_search_params }
    assert Issue.search(issue_search)[0] == @other_issue
  end

  test "search should find issues crated by user" do
    issue_search_params = { search: "", status:  "", assigned_user_id: "", creator_user_id: @other_user.id }
    issue_search = { search_params: issue_search_params }
    assert Issue.search(issue_search)[0] == @other_issue
  end

  test "search should not find issue that does not exist" do
    issue_search_params = { search: "LOL", status:  @other_issue.status, assigned_user_id: @user.id, creator_user_id: @other_user.id }
    issue_search = { search_params: issue_search_params }
    assert_empty Issue.search(issue_search)
  end

  test "user serach should return assigned issue" do
    issue_search_params = { search: "", status: "" }
    issue_search = { search_params: issue_search_params, user_id: @user.id }
    assert Issue.search(issue_search)[0] == @issue
  end

  test "user search should return nothing if user_id is not passed in" do
    issue_search_params = { search: "", status: "" }
    issue_search = { search_params: issue_search_params, user_id: "" }
    assert Issue.search(issue_search).empty?
  end

  test "user search should look in title" do
    issue_search_params = { search: "first", status: "" }
    issue_search = { search_params: issue_search_params, user_id: @user.id }
    assert Issue.search(issue_search)[0] == @issue
  end

  test "user search should look in description" do
    issue_search_params = { search: "LOL", status: "" }
    issue_search = { search_params: issue_search_params, user_id: @user.id }
    assert Issue.search(issue_search)[0] == @issue
  end

  test "user search should find status" do
    issue_search_params = { search: "", status: @other_issue.status }
    issue_search = { search_params: issue_search_params, user_id: @other_user.id }
    assert Issue.search(issue_search)[0] == @other_issue
  end
end
