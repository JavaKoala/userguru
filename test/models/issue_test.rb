require 'test_helper'

class IssueTest < ActiveSupport::TestCase
  
  def setup
    @user = users(:one)
    @issue = Issue.new(title: "test title", description: "I have a problem", user_id: @user.id)
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
end
