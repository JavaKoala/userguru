require 'test_helper'

class Api::V1::IssuesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @customer1 = users(:customer1)
    add_roles_to_users
  end

  test 'should not get index without authorization header' do
    get api_v1_issues_path, params: { title: '' }
    assert_response :unauthorized
  end

  test 'should not get index with wrong authorization header' do
    get api_v1_issues_path, params: { title: '' },
                            headers: { 'authorization' => 'SUCKIT' }
    assert_response :unauthorized
  end

  test 'should get index' do
    get api_v1_issues_path, params: { title: '' }, 
                            headers: { 'authorization' => @customer1.auth_token }
    assert_response :success
  end

  test 'should get index with authorization token creation' do
    post api_v1_sessions_path, params: { session: { email: @customer1.email, password: 'password' } }
    assert_response :success
    body = JSON.parse(response.body)
    @customer1.reload
    customer1_auth_token = body['auth_token']
    get api_v1_issues_path, params: { title: '' }, 
                            headers: { 'authorization' => customer1_auth_token }
    assert_response :success
  end

  test 'should get issues with Customer in the title' do
    get api_v1_issues_path, params: { title: Issue.first.title }, 
                            headers: { 'authorization' => @customer1.auth_token }
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal Issue.first.title, body['title']
  end
end
