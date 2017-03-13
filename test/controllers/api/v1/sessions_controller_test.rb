require 'test_helper'

class Api::V1::SessionsControllerTest < ActionController::TestCase

  def setup
    @customer1 = users(:customer1)
    add_roles_to_users
  end

  test 'api login with correct credentials' do
    post :create, params: { session: { email: @customer1.email, password: 'password' } }
    assert_response :success
    body = JSON.parse(response.body)
    @customer1.reload
    assert_equal @customer1.auth_token, body['auth_token']
  end

  test 'api login with incorrect password' do
    post :create, params: { session: { email: @customer1.email, password: 'LOL' } }
    assert_response 401
    body = JSON.parse(response.body)
    assert_equal 'Invalid email or password', body['errors']
  end

  test 'api login with incorrect email' do
    post :create, params: { session: { email: 'LOL', password: 'password' } }
    assert_response 401
    body = JSON.parse(response.body)
    assert_equal 'Invalid email or password', body['errors']
  end

  test 'api login with no roles' do
    # remove role from customer1
    @customer1.roles.delete(Role.where(name: 'customer'))
    post :create, params: { session: { email: @customer1.email, password: 'password' } }
    assert_response 401
    body = JSON.parse(response.body)
    assert_equal 'Invalid email or password', body['errors']
  end
end
