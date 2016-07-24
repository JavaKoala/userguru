require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end
  
  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name:     "",
                                         email:    "user@invalid",
                                         password: "foo",
                                         password_confirmation: "bar" } }
      assert_response :success
    end
  end
  
  test "valid signup information with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name: "Example User",
                                         email: "user@example.com",
                                         password: "password",
                                         pasword_confirmation: "password" } }
      follow_redirect!
    end
    assert_response :success
    assert_equal 1, ActionMailer::Base.deliveries.size
  end
end
