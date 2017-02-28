require 'test_helper'

class Api::V1::IssueControllerTest < ActionController::TestCase
  test "should get show" do
    get :show, { params: {'title' => ''} }
    assert_response :success
  end

end
