require 'test_helper'

class CommentTest < ActiveSupport::TestCase

  def setup
    @user = users(:one)
    @issue = issues(:one)
  end

  test "Issue should not be valid without a user and issue" do
    @comment = Comment.new(text: "this should not be valid")
    assert_not @comment.valid?
  end

  test "Issue should not be valid without an issue" do
    @comment = Comment.new(text: "this should not be valid", user_id: @user.id)
    assert_not @comment.valid?
  end

  test "Issue should not be valid without a user" do
    @comment = Comment.new(text: "this should not be valid", issue_id: @issue.id)
    assert_not @comment.valid?
  end

  test "Issue should not be valid if the text is too long" do
    comment_text = "a" * 256
    @comment = Comment.new(text: comment_text, issue_id: @issue.id, user_id: @user.id)
    assert_not @comment.valid?
  end

  test "Issue should be valid if it has an inssue, user and the text is not too long" do
    @comment = Comment.new(text: "valid text", issue_id: @issue.id, user_id: @user.id)
    assert @comment.valid?
  end
end
