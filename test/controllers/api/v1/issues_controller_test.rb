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
    assert_equal @customer2.issues.first.title, body[0]['title']
  end

  test 'should get show for customer1 issue, should include comments' do
    get api_v1_issue_path(@customer1_issue.id), headers: { 'authorization' => @customer1.auth_token }
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal @customer1_issue.description, body['description']
    assert_equal @customer1_comment.text, body['comments'].last['text']
    assert_equal @customer1_comment2.text, body['comments'].first['text']
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
end
