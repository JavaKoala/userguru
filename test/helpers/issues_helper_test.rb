require 'test_helper'

class IssuesHelperTest < ActionView::TestCase

  include SessionsHelper

  def setup
    # Set up users
    @customer1           = users(:customer1)
    @representative_user = users(:representative)
    add_roles_to_users

    # Set up issue
    @customer1_issue     = issues(:customer1_issue)
    add_user_issue
  end

  test 'should retrun the issue creators name' do
    assert issue_creator_name(@customer1_issue) == @customer1.name
  end

  test 'should return false if there is no assigned user' do
    assert has_assigned_user?(@customer1_issue) == false
  end

  test 'should return true if there is an assigned user' do
    @customer1_issue.user_issue.user_id = @representative_user.id
    assert has_assigned_user?(@customer1_issue) == true
  end
  
  test 'should return Not Assigned if there is no assigned user' do
    assert assigned_user_name(@customer1_issue) == "A representative will be assigned shortly"
  end

  test 'should return Please assign user for internal user and no assigned user' do
    log_in_as(@representative_user)
    assert assigned_user_name(@customer1_issue) == "Please assign user"
  end
  
  test 'should return user name if there is an assigned user' do
    @customer1_issue.user_issue.user_id = @representative_user.id
    assert assigned_user_name(@customer1_issue) == @representative_user.name
  end

  test 'should return nil if there is no assigned user' do
    assert assigned_user_id(@customer1_issue) == nil
  end

  test 'should return user id if there is an assigned user' do
    @customer1_issue.user_issue.user_id = @representative_user.id
    assert assigned_user_id(@customer1_issue) == @representative_user.id
  end

  test 'should return true if the user_id is the same as the current user' do
    log_in_as(@customer1)
    assert current_user == @customer1
    assert user_comment?(@customer1.id) == true
  end

  test 'should return false if the user id is different than the current user' do
    log_in_as(@customer1)
    assert current_user == @customer1
    assert user_comment?(@representative_user.id) == false
  end

  test 'should return the users name' do
    assert commenter_name(@customer1.id) == @customer1.name
  end
end