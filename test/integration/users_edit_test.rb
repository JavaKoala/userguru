require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  include SessionsHelper

  def setup
    @user = users(:one)
    @user.roles << Role.where(name: 'customer')
    @other_user = users(:two)
    @other_user.roles << Role.where(name: 'customer')
  end
  
  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_response :success
    patch user_path(@user), params: { user: { name: '',
                                              email: 'foo@invalid',
                                              password: 'foo',
                                              password_confirmation: 'bar' } }
    assert_response :success                                     
  end
  
  test "successful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_response :success
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name: name,
                                              email: email,
                                              password: "",
                                              password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal @user.name, name
    assert_equal @user.email, email                                 
  end
  
  test "successful admin edit" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert_redirected_to login_url
    delete logout_path
    follow_redirect!
    assert_not is_logged_in?
    @user.roles << Role.where(name: 'admin')
    log_in_as(@user)
    get edit_user_path(@other_user)
    assert_response :success
    name = "Foo Bar"
    email = "foo@bar.com"
    admin_role = Role.select(:id).where(name: 'admin')
    respresntative_role = Role.select(:id).where(name: 'representative')
    customer_role = Role.select(:id).where(name: 'customer')
    patch user_path(@other_user), params: { user: { name: name,
                                                    email: email,
                                                    password: "",
                                                    password_confirmation: "",
                                                    role_id: [admin_role, respresntative_role, customer_role] } }
    assert_redirected_to @other_user
  end
  
  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    log_in_as(@user)
    get edit_user_path(@user)
    assert_response :success
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name: name,
                                              email: email,
                                              password: "foobar",
                                              password_confirmation: "foobar" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal @user.name, name
    assert_equal @user.email, email
  end
end
