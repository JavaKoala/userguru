require 'test_helper'

class CommentsControllerTest < ActionDispatch::IntegrationTest

  def setup
    # Set up users
    @customer1           = users(:customer1)
    @customer2           = users(:customer2)
    @admin_user          = users(:admin_user)
    add_roles_to_users

    # Set up issue
    @customer1_issue     = issues(:customer1_issue)
    add_user_issue

    # Set up comment
    @customer1_comment   = comments(:customer1_comment)

  end

  test "should create new comment" do
    log_in_as(@customer1)
    get @customer1_issue_path
    assert_difference 'Comment.count', 1 do
      post comments_path, params: { comment: { text: "test title" },
                                    issue_id: @customer1_issue.id }
    end
  end

  test "should not create new comment when not logged in" do
    assert_no_difference 'Comment.count' do
      post comments_path, params: { comment: { text: "test title" },
                                               issue_id: @customer1_issue.id }
    end
  end

  test "should not create new comment if there is no text" do
    log_in_as(@customer1)
    get @customer1_issue_path
    assert_no_difference 'Comment.count' do
      post comments_path, params: { comment: { text: "" },
                                    issue_id: @customer1_issue.id }
      assert_not flash.empty?
    end
  end

  test "should not create comment if text is too long" do
    log_in_as(@customer1)
    get @customer1_issue_path
    comment_text = "a" * 256
    assert_no_difference 'Comment.count' do
      post comments_path, params: { comment: { text: comment_text },
                                    issue_id: @customer1_issue.id }
      assert_not flash.empty?
    end
  end

  test "should update comment" do
    log_in_as(@customer1)
    get @customer1_issue_path
    patch comment_path(@customer1_comment), params: { comment: { text: "updated comment",
                                                                 issue_id: @customer1_issue.id } }
    follow_redirect!
    assert_response :success
    assert @customer1_comment.text = "updated comment"
  end

  test "should not update comment if it is done by the wrong user" do
    original_text = @customer1_comment.text
    log_in_as(@customer2)
    get @customer1_issue_path
    patch comment_path(@customer1_comment), params: { comment: { text: "updated comment",
                                                                issue_id: @customer1_issue.id } }
    follow_redirect!
    assert_response :success
    assert @customer1_comment.text = original_text
  end

  test "should not update comment if the text is blank" do
    original_text = @customer1_comment.text
    log_in_as(@customer1)
    get @customer1_issue_path
    assert_not @customer1_comment.update_attributes(text: "", issue_id: @customer1_issue.id)
    patch comment_path(@customer1_comment), params: { comment: { text: "",
                                                                 issue_id: @customer1_issue.id } }
    follow_redirect!
    assert_response :success
    assert @customer1_comment.text = original_text
  end

  test "should not update comment if the text too long" do
    original_text = @customer1_comment.text
    log_in_as(@customer1)
    get @customer1_issue_path
    comment_text = "a" * 256
    assert_not @customer1_comment.update_attributes(text: comment_text, issue_id: @customer1_issue.id)
    patch comment_path(@customer1_comment), params: { comment: { text: comment_text,
                                                                 issue_id: @customer1_issue.id } }
    follow_redirect!
    assert_response :success
    assert @customer1_comment.text = original_text
  end

  test "should redirect delete when not logged in" do
    assert_no_difference 'Comment.count' do
      delete comment_path(@customer1_comment), params: { id: @customer1_comment.id,
                                                         issue_id: @customer1_issue.id }
    end
    assert_redirected_to login_url
  end

  test "should delete comment" do
    log_in_as(@admin_user)
    assert_difference 'Comment.count', -1 do
      delete comment_path(@customer1_comment), params: { id: @customer1_comment.id,
                                                         issue_id: @customer1_issue.id }
    end
  end

  test "should not delete comment if not an admin user" do
    log_in_as(@customer1)
    assert_no_difference 'Comment.count' do
      delete comment_path(@customer1_comment), params: { id: @customer1_comment.id,
                                                         issue_id: @customer1_issue.id }
    end
  end
end
