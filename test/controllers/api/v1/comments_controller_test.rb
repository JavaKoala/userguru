require 'test_helper'

class Api::V1::CommentsControllerTest < ActionDispatch::IntegrationTest

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

  test 'should create comment' do
    assert_difference 'Comment.count', 1 do
      post api_v1_comments_path, params: { text: "I like new comments", issue_id: @customer1_issue.id },
                                 headers: { 'authorization' => @customer1.auth_token }
      assert_response 201
      body = JSON.parse(response.body)
      assert_equal body["id"], @customer1_issue.id
      assert_equal body["comments"][0]["text"], "I like new comments"
      assert_equal body["comments"][0]["commenter_name"], @customer1.name
      assert_equal body["comments"][0]["commenter_email"], @customer1.email
    end
  end

  test 'should not create comment with the wrong authorization' do
    post api_v1_comments_path, params: { text: "I like new comments", issue_id: @customer1_issue.id },
                               headers: { 'authorization' => "wrong and sad" }
    assert_response :unauthorized
  end

  test 'customer2 should not be able to comment on customer1s issue' do
    post api_v1_comments_path, params: { text: "I like new comments", issue_id: @customer1_issue.id },
                               headers: { 'authorization' => @customer2.auth_token }
    assert_response :unauthorized
  end

  test 'admin user should be able to comment on customer1s issue' do
    post api_v1_comments_path, params: { text: "Wow that looks bad", issue_id: @customer1_issue.id },
                               headers: { 'authorization' => @admin_user.auth_token }
    assert_response 201
    body = JSON.parse(response.body)
    assert_equal body["id"], @customer1_issue.id
    assert_equal body["comments"][0]["text"], "Wow that looks bad"
    assert_equal body["comments"][0]["commenter_name"], @admin_user.name
    assert_equal body["comments"][0]["commenter_email"], @admin_user.email
  end

  test 'should not create comment with blank text' do
    post api_v1_comments_path, params: { text: "", issue_id: @customer1_issue.id },
                               headers: { 'authorization' => @customer1.auth_token }
    assert_response 400
  end

  test 'should not create comment with the wrong issue id' do
    post api_v1_comments_path, params: { text: "", issue_id: @customer1_issue.id + 1 },
                               headers: { 'authorization' => @customer1.auth_token }
    assert_response 404
  end
end
