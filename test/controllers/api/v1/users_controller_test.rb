require 'test_helper'

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @admin_user = users(:admin_user)
    @customer1  = users(:customer1)
    @customer2  = users(:customer2)
    add_roles_to_users
    add_user_issue

    # Clear ActionMailer
    ActionMailer::Base.deliveries.clear
  end

  test 'should create user' do
    assert_difference 'User.count', 1 do
      post api_v1_users_path, params: { name: "New api user", 
                                        email: "apiuser@apitest.com", 
                                        password: "TopSecretPassword!1" }
      assert_response 201
      body = JSON.parse(response.body)
      assert_equal body["activation"], "Please check your email to activate your account."
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test 'should not create user with no name' do
    assert_no_difference 'User.count' do
      post api_v1_users_path, params: { email: "apiuser@apitest.com", 
                                        password: "TopSecretPassword!1" }
      assert_response 400
    end
    assert_equal 0, ActionMailer::Base.deliveries.size
  end

  test 'should not create user with no email' do
    assert_no_difference 'User.count' do
      post api_v1_users_path, params: { name: "New api user", 
                                        password: "TopSecretPassword!1" }
      assert_response 400
    end
    assert_equal 0, ActionMailer::Base.deliveries.size
  end

  test 'should not create user with no password' do
    assert_no_difference 'User.count' do
      post api_v1_users_path, params: { name: "New api user", 
                                        email: "apiuser@apitest.com" }
      assert_response 400
    end
    assert_equal 0, ActionMailer::Base.deliveries.size
  end

  test 'should not create user with invalid name' do
    assert_no_difference 'User.count' do
      post api_v1_users_path, params: { name: "",
                                        email: "apiuser@apitest.com", 
                                        password: "TopSecretPassword!1" }
      assert_response 400
    end
    assert_equal 0, ActionMailer::Base.deliveries.size
  end

  test 'should not create user with invalid email' do
    assert_no_difference 'User.count' do
      post api_v1_users_path, params: { name: "New api user",
                                        email: "apiuserapitest.com", 
                                        password: "TopSecretPassword!1" }
      assert_response 400
    end
    assert_equal 0, ActionMailer::Base.deliveries.size
  end

  test 'should not create user with invalid password' do
    assert_no_difference 'User.count' do
      post api_v1_users_path, params: { name: "New api user",
                                        email: "apiuser@apitest.com", 
                                        password: "test" }
      assert_response 400
    end
    assert_equal 0, ActionMailer::Base.deliveries.size
  end

end
