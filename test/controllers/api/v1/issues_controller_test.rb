require 'test_helper'

class Api::V1::IssuesControllerTest < ActionController::TestCase
  test 'should get index' do
    get :index, params: { title: '' }
    assert_response :success
  end

  test 'should get issues with Customer in the title' do
    get :index, params: { title: Issue.first.title }
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal Issue.first.title, body['title']
  end
end
