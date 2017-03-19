require 'test_helper'

class Api::V1::ApiUsersAuthenticationTest < ActionDispatch::IntegrationTest

  include SessionsHelper

  def setup
    @admin_user          = users(:admin_user)
    @customer1           = users(:customer1)
    @representative_user = users(:representative)
    add_roles_to_users
  end

  test 'api user should return the user with the given auth_token' do
    get root_path, headers: { 'authorization' => @customer1.auth_token }
    assert_equal api_user, @customer1
    assert current_api_user?
    assert_not internal_api_user?
    assert_not admin_api_user?
  end

  test 'api user should not return a user with an invalid auth_token' do
    get root_path, headers: { 'authorization' => 'LOL, wut?' }
    assert_nil api_user
    assert_not current_api_user?
    assert_not internal_api_user?
    assert_not admin_api_user?
  end

  test 'api user should be internal if they are internal' do
    get root_path, headers: { 'authorization' => @representative_user.auth_token }
    assert_equal api_user, @representative_user
    assert internal_api_user?
    assert_not admin_api_user?
  end

  test 'api user should be admin if they are admin' do
    get root_path, headers: { 'authorization' => @admin_user.auth_token }
    assert_equal api_user, @admin_user
    assert internal_api_user?
    assert admin_api_user?
  end
end
