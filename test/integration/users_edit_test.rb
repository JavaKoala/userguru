require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  include SessionsHelper

  def setup
    @customer1  = users(:customer1)
    @customer2  = users(:customer2)
    @admin_user = users(:admin_user)
    add_roles_to_users
  end
  
  test "unsuccessful edit" do
    log_in_as(@customer1)
    get edit_user_path(@customer1)
    assert_response :success
    patch user_path(@customer1), params: { user: { name: '',
                                                   email: 'foo@invalid',
                                                   password: 'foo',
                                                   password_confirmation: 'bar' } }
    assert_response :success
  end
  
  test "successful edit" do
    log_in_as(@customer1)
    get edit_user_path(@customer1)
    assert_response :success
    name = "Foo Bar"
    email = "foo@bar.com"
    auth_token = @customer1.auth_token
    patch user_path(@customer1), params: { user: { name: name,
                                                   email: email,
                                                   password: "",
                                                   password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @customer1
    @customer1.reload
    assert_equal @customer1.name, name
    assert_equal @customer1.email, email
    assert_not_equal @customer1.auth_token, auth_token
  end
  
  test "successful admin edit" do
    log_in_as(@customer2)
    get edit_user_path(@customer1)
    assert_redirected_to login_url
    delete logout_path
    follow_redirect!
    assert_not is_logged_in?
    log_in_as(@admin_user)
    get edit_user_path(@customer2)
    assert_response :success
    name = "Foo Bar"
    email = "foo@bar.com"
    admin_role = Role.select(:id).where(name: 'admin')
    respresntative_role = Role.select(:id).where(name: 'representative')
    customer_role = Role.select(:id).where(name: 'customer')
    patch user_path(@customer2), params: { user: { name: name,
                                                   email: email,
                                                   password: "",
                                                   password_confirmation: "",
                                                   role_id: [admin_role, respresntative_role, customer_role] } }
    assert_redirected_to @customer2
  end
  
  test "successful edit with friendly forwarding" do
    get edit_user_path(@customer1)
    log_in_as(@customer1)
    get edit_user_path(@customer1)
    assert_response :success
    name  = "Foo Bar"
    email = "foo@bar.com"
    auth_token = @customer1.auth_token
    patch user_path(@customer1), params: { user: { name: name,
                                                   email: email,
                                                   password: "foobar",
                                                   password_confirmation: "foobar" } }
    assert_not flash.empty?
    assert_redirected_to @customer1
    @customer1.reload
    assert_equal @customer1.name, name
    assert_equal @customer1.email, email
    assert_not_equal @customer1.auth_token, auth_token
  end
end
