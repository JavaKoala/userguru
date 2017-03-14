require 'test_helper'

class Api::V1::IssuesControllerTest < ActionController::TestCase
  test "should get show" do
    get :show, { params: {'title' => ''} }
    assert_response :success
  end
end
