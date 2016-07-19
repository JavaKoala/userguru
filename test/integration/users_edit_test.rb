require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:one)
  end
  
  test "unsuccessful edit" do
    get edit_user_path(@user)
    assert_response :success
    patch user_path(@user), params: { user: { name: '',
                                              email: 'foo@invalid',
                                              password: 'foo',
                                              password_confirmation: 'bar' } }
    assert_response :success                                     
  end
  
  test "successful edit" do
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
end
