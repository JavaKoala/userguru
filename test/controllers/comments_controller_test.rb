require 'test_helper'

class CommentsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user  = users(:one)
    @user.roles << Role.where(name: 'customer')
    @other_user = users(:two)
    @other_user.roles << Role.where(name: 'admin')
    @issue = issues(:one)
    @comment = comments(:one)
    @comment.user_id  = @user.id
    @comment.issue_id = @issue.id
  end

  test "should create new comment" do
    log_in_as(@user)
    get @issue_path
    assert_difference 'Comment.count', 1 do
      post comments_path, params: { comment: { text: "test title" },
                                    issue_id: @issue.id }
    end
  end

  test "should not create new comment when not logged in" do
    assert_no_difference 'Comment.count' do
      post comments_path, params: { comment: { text: "test title" },
                                               issue_id: @issue.id }
    end
  end

  test "should not create new comment if there is no text" do
    log_in_as(@user)
    get @issue_path
    assert_no_difference 'Comment.count' do
      post comments_path, params: { comment: { text: "" },
                                    issue_id: @issue.id }
    end
  end

  test "should flash message if comment is too long" do
    log_in_as(@user)
    get @issue_path
    comment_text = "a" * 256
    post comments_path, params: { comment: { text: comment_text },
                                    issue_id: @issue.id }
    assert_not flash.empty?
  end

  test "should update comment" do
    log_in_as(@user)
    get @issue_path
    patch comment_path(@comment), params: { comment: { text: "updated comment",
                                                       issue_id: @issue.id } }
    follow_redirect!
    assert_response :success
    assert @comment.text = "updated comment"
  end

  test "should not update comment if it is done by the wrong user" do
    original_text = @comment.text
    log_in_as(@other_user)
    get @issue_path
    patch comment_path(@comment), params: { comment: { text: "updated comment",
                                                       issue_id: @issue.id } }
    follow_redirect!
    assert_response :success
    assert @comment.text = original_text
  end

  test "should not update comment if the text is blank" do
    original_text = @comment.text
    log_in_as(@user)
    get @issue_path
    patch comment_path(@comment), params: { comment: { text: "",
                                                       issue_id: @issue.id } }
    follow_redirect!
    assert_response :success
    assert @comment.text = original_text
  end

  test "should redirect delete when not logged in" do
    assert_no_difference 'Comment.count' do
      delete comment_path(@comment), params: { id: @comment.id,
                                               issue_id: @issue.id }
    end
    assert_redirected_to login_url
  end

  test "should delete comment" do
    log_in_as(@other_user)
    assert_difference 'Comment.count', -1 do
      delete comment_path(@comment), params: { id: @comment.id,
                                               issue_id: @issue.id }
    end
  end

  test "should not delete comment if not an admin user" do
    log_in_as(@user)
    assert_no_difference 'Comment.count' do
      delete comment_path(@comment), params: { id: @comment.id,
                                               issue_id: @issue.id }
    end
  end
end
