require 'test_helper'

class CommentsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user  = users(:one)
    @user.roles << Role.where(name: 'customer')
    @issue = issues(:one)
  end

  test "should create new comment" do
    log_in_as(@user)
    get @issue_path
    assert_difference 'Comment.count', 1 do
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
end
