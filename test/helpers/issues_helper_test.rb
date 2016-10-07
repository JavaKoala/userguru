require 'test_helper'

class IssuesHelperTest < ActionView::TestCase

  include SessionsHelper

  def setup
    @user  = users(:one)
    @user.roles << Role.where(name: 'representative')
    @other_user  = users(:two)
    @issue = issues(:one)
    @issue.user_issue = UserIssue.new
  end

  test 'should retrun the issue creators name' do
    assert issue_creator_name(@issue) == @user.name
  end

  test 'should return false if there is no assigned user' do
    assert has_assigned_user?(@issue) == false
  end

  test 'should return true if there is an assigned user' do
    @issue.user_issue.user_id = @user.id
    assert has_assigned_user?(@issue) == true
  end
  
  test 'should return Not Assigned if there is no assigned user' do
    assert assigned_user_name(@issue) == "Not Assigned"
  end
  
  test 'should return user name if there is an assigned user' do
    @issue.user_issue.user_id = @user.id
    assert assigned_user_name(@issue) == @user.name
  end

  test 'should return nil if there is no assigned user' do
    assert assigned_user_id(@issue) == nil
  end

  test 'should return user id if there is an assigned user' do
    @issue.user_issue.user_id = @user.id
    assert assigned_user_id(@issue) == @user.id
  end

  test 'should return true if the user_id is the same as the current user' do
    log_in_as(@user)
    assert current_user == @user
    assert user_comment?(@user.id) == true
  end

  test 'should return false if the user id is different than the current user' do
    log_in_as(@user)
    assert current_user == @user
    assert user_comment?(@other_user.id) == false
  end

  test 'should return the users name' do
    assert commenter_name(@user.id) == @user.name
  end
end