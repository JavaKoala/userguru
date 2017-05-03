require 'test_helper'

class Api::V1::IssuesControllerTest < ActionDispatch::IntegrationTest

  def setup
    # Setup users
    @representative_user = users(:representative)
    @customer1           = users(:customer1)
    @customer2           = users(:customer2)
    add_roles_to_users

    # Setup issues
    @customer1_issue = issues(:customer1_issue)
    @customer2_issue = issues(:customer2_issue)
    add_user_issue

    # Set up comments 
    @customer1_comment = comments(:customer1_comment)
    @customer1_comment.issue_id = @customer1_issue.id
    @customer1_comment.user_id = @customer1.id
    @customer1_comment.save
    @customer1_comment.reload

    @customer1_comment2 = comments(:customer1_comment2)
    @customer1_comment2.issue_id = @customer1_issue.id
    @customer1_comment2.user_id = @customer1.id
    @customer1_comment2.save
    @customer1_comment2.reload
  end

  test 'should not get index without authorization header' do
    get api_v1_issues_path, params: { search: '' }
    assert_response :unauthorized
  end

  test 'should not get index with wrong authorization header' do
    get api_v1_issues_path, params: { search: '' },
                            headers: { 'authorization' => 'SUCKIT' }
    assert_response :unauthorized
  end

  test 'should get index' do
    get api_v1_issues_path, params: { search: '' }, 
                            headers: { 'authorization' => @customer1.auth_token }
    assert_response :success
  end

  test 'should get index with authorization token creation' do
    get api_v1_sessions_path, params: { email: @customer1.email, password: 'password' }
    assert_response :success
    body = JSON.parse(response.body)
    @customer1.reload
    customer1_auth_token = body['auth_token']
    get api_v1_issues_path, params: { search: '' }, 
                            headers: { 'authorization' => customer1_auth_token }
    assert_response :success
  end

  test 'should get customer1 first issue when searched by customer1' do
    get api_v1_issues_path, params: { search: @customer1.issues.first.title }, 
                            headers: { 'authorization' => @customer1.auth_token }
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal @customer1.name, body[0]['user']['name']
    assert_equal @customer1.email, body[0]['user']['email']
    assert_equal @customer1.issues.first.title, body[0]['title']
  end

  test 'customer1 should not be able to see customer2 issues' do
    get api_v1_issues_path, params: { search: @customer2.issues.first.title }, 
                            headers: { 'authorization' => @customer1.auth_token }
    assert_response :success
    body = JSON.parse(response.body)
    assert_empty body
  end

  test 'representative_user should be able to see customer2 issues' do
    get api_v1_issues_path, params: { search: @customer2.issues.first.description }, 
                            headers: { 'authorization' => @representative_user.auth_token }
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal @customer2.name, body[0]['user']['name']
    assert_equal @customer2.email, body[0]['user']['email']
    assert_equal @customer2.issues.first.title, body[0]['title']
  end

  test 'should get show for customer1 issue, should include comments' do
    get api_v1_issue_path(@customer1_issue.id), headers: { 'authorization' => @customer1.auth_token }
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal @customer1_issue.description, body['description']
    assert_equal @customer1_comment.text, body['comments'].last['text']
    assert_equal @customer1.name, body['comments'].last['commenter_name']
    assert_equal @customer1.email, body['comments'].last['commenter_email']
    assert_equal @customer1_comment2.text, body['comments'].first['text']
    assert_equal @customer1.name, body['comments'].first['commenter_name']
    assert_equal @customer1.email, body['comments'].first['commenter_email']
  end

  test 'customer1 should not be able to see customer2 issue' do
    get api_v1_issue_path(@customer2_issue.id), headers: { 'authorization' => @customer1.auth_token }
    assert_response :unauthorized
  end

  test 'representative_user should be able to see customer2 issue' do
    get api_v1_issue_path(@customer2_issue.id), headers: { 'authorization' => @representative_user.auth_token }
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal @customer2_issue.title, body['title']
  end

  test 'should receive a 404 for an issue that doesnt exist' do
    get api_v1_issue_path(@customer2_issue.id + 1), headers: { 'authorization' => @representative_user.auth_token }
    assert_response 404
  end

  test 'should create issue' do
    assert_difference 'UserIssue.count', 1 do
      post api_v1_issues_path, params: { title: "test title", description: "test description" },
                               headers: { 'authorization' => @representative_user.auth_token }
      assert_response 201
      body = JSON.parse(response.body)
      assert_equal body["title"], "test title"
      assert_equal body["description"], "test description"
    end
  end

  test 'should not create issue if there is no title' do
    assert_no_difference 'UserIssue.count', 1 do
      post api_v1_issues_path, params: { title: "", description: "test description" },
                               headers: { 'authorization' => @representative_user.auth_token }
      assert_response 400
    end
  end

  test 'should not create issue if there is no description' do
    assert_no_difference 'UserIssue.count', 1 do
      post api_v1_issues_path, params: { title: "test title", description: "" },
                               headers: { 'authorization' => @representative_user.auth_token }
      assert_response 400
    end
  end

  test 'should not create issue if the authorization is wrong' do
    assert_no_difference 'UserIssue.count', 1 do
      post api_v1_issues_path, params: { title: "test title", description: "test description" },
                               headers: { 'authorization' => "LOLWUT" }
      assert_response :unauthorized
    end
  end

  test 'should update issue' do
    patch api_v1_issue_path(@customer1_issue.id), params: { title: "updated title", description: "new description" },
                                                  headers: { 'authorization' => @customer1.auth_token }
    assert_response :success
    @customer1_issue.reload
    assert_equal @customer1_issue.title, "updated title"
    assert_equal @customer1_issue.description, "new description"
  end

  test 'should not be able to update issue with wrong authorization' do
    patch api_v1_issue_path(@customer1_issue.id), params: { title: "updated title", description: "new description" },
                                                  headers: { 'authorization' => "ICANHASTOKEN" }
    assert_response :unauthorized
  end

  test 'should not be able to update issue with wrong id' do
    patch api_v1_issue_path(@customer1_issue.id + 1), params: { title: "updated title", description: "new description" },
                                                      headers: { 'authorization' => @representative_user.auth_token }
    assert_response 404
  end

  test 'customer1 should not be able to update customer2s issue' do
    patch api_v1_issue_path(@customer2_issue), params: { title: "updated title", description: "new description" },
                                               headers: { 'authorization' => @customer1.auth_token }
    assert_response :unauthorized
  end

  test 'representative_user should be able to update customer2s issue' do
    patch api_v1_issue_path(@customer2_issue), params: { title: "updated title", description: "new description" },
                                               headers: { 'authorization' => @representative_user.auth_token }
    assert_response :success
    @customer2_issue.reload
    assert_equal @customer2_issue.title, "updated title"
    assert_equal @customer2_issue.description, "new description"
  end

  test 'should not be able to update issue with invalid params' do
    patch api_v1_issue_path(@customer1_issue.id), params: { title: "", description: "" },
                                                  headers: { 'authorization' => @customer1.auth_token }
    assert_response 400
  end
end
