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

  test 'should return user' do
    get api_v1_users_path, params: { email: @customer1.email },
                           headers: { 'authorization' => @customer1.auth_token }
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal body["id"], @customer1.id
    assert_equal body["name"], @customer1.name
    assert_equal body["email"], @customer1.email
    assert_equal body.length, 3
  end

  test 'admin user should not be able to see customer1' do
    get api_v1_users_path, params: { email: @customer1.email },
                           headers: { 'authorization' => @admin_user.auth_token }
    assert_response 400
    body = JSON.parse(response.body)
    assert_equal body["errors"], "Bad Request"
    assert_equal body.length, 1
  end

  test 'should not return user with an invalid email' do
    get api_v1_users_path, params: { email: "hellothere@test.com" },
                           headers: { 'authorization' => @admin_user.auth_token }
    assert_response 400
    body = JSON.parse(response.body)
    assert_equal body["errors"], "Bad Request"
    assert_equal body.length, 1
  end

  test 'should not return user with an invalid authorization token' do
    get api_v1_users_path, params: { email: @customer1.email },
                           headers: { 'authorization' => "ICanHazToken" }
    assert_response :unauthorized
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

  test 'should update user name, email and password' do
    original_password = @customer2.password_digest
    # first get the users id
    get api_v1_users_path, params: { email: @customer2.email },
                           headers: { 'authorization' => @customer2.auth_token }
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal body["id"], @customer2.id
    user_id = body["id"]
    patch api_v1_user_path(user_id), params: { name: "updated name",
                                               email: "updated_email@testupdate.biz",
                                               password: "UpdatedPassword!" },
                                               headers: { 'authorization' => @customer2.auth_token }
    assert_response :success
    @customer2.reload
    body = JSON.parse(response.body)
    assert_equal body["id"], @customer2.id
    assert_equal body["name"], "updated name"
    assert_equal body["email"], "updated_email@testupdate.biz"
    assert_not_equal original_password, @customer2.password_digest
    assert_not_equal @customer2.password_digest, "UpdatedPassword!"
  end

  test 'should not update user with invalid auth_token' do
    patch api_v1_user_path(@customer2.id), params: { name: "updated name",
                                                     email: "updated_email@testupdate.biz",
                                                     password: "UpdatedPassword!" },
                                                     headers: { 'authorization' => "invalid_token" }
    assert_response :unauthorized
  end

  test 'should not update user with invalid user id' do
    patch api_v1_user_path(@customer2.id + 1), params: { name: "updated name",
                                                         email: "updated_email@testupdate.biz",
                                                         password: "UpdatedPassword!" },
                                                         headers: { 'authorization' => @customer2.auth_token }
    assert_response 400
  end

  test 'should not be able to modify another users information' do
    patch api_v1_user_path(@customer2.id), params: { name: "updated name",
                                                     email: "updated_email@testupdate.biz",
                                                     password: "UpdatedPassword!" },
                                                     headers: { 'authorization' => @admin_user.auth_token }
    assert_response 400
  end

  test 'should not be able to update a user with an invalid name' do
    patch api_v1_user_path(@customer2.id), params: { name: "",
                                                     email: "updated_email@testupdate.biz",
                                                     password: "UpdatedPassword!" },
                                                     headers: { 'authorization' => @customer2.auth_token }
    assert_response 400
  end

  test 'should not be able to update a user with an invalid email' do
    patch api_v1_user_path(@customer2.id), params: { name: "updated name",
                                                     email: "updated_email@testupdate",
                                                     password: "UpdatedPassword!" },
                                                     headers: { 'authorization' => @customer2.auth_token }
    assert_response 400
  end

  test 'should not be able to update a user with an blank password' do
    patch api_v1_user_path(@customer2.id), params: { name: "updated name",
                                                     email: "updated_email@testupdate.biz",
                                                     password: "" },
                                                     headers: { 'authorization' => @customer2.auth_token }
    assert_response 400
  end

  test 'should not be able to update a user with an invalid password' do
    patch api_v1_user_path(@customer2.id), params: { name: "updated name",
                                                     email: "updated_email@testupdate.biz",
                                                     password: "123" },
                                                     headers: { 'authorization' => @customer2.auth_token }
    assert_response 400
  end

  test 'should be able to only update the password' do
    user_name     = @customer2.name
    user_email    = @customer2.email
    user_password = @customer2.password_digest
    patch api_v1_user_path(@customer2.id), params: { password: "new_password" },
                                                     headers: { 'authorization' => @customer2.auth_token }
    assert_response :success
    @customer2.reload
    assert_equal user_name,  @customer2.name
    assert_equal user_email, @customer2.email
    assert_not_equal user_password, @customer2.password_digest
  end
end
