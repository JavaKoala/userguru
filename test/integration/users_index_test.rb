require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:one)
    @user.roles << Role.where(name: 'customer')
    @other_user = users(:two)
    @other_user.roles << Role.where(name: 'customer')
  end
  
  test "index as admin including pagination, edit and delete links" do
    log_in_as(@user)
    get users_path
    assert_redirected_to login_url
    @user.roles << Role.where(name: 'admin')
    get users_path
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      assert_select 'a[href=?]', edit_user_path(user), text: 'Edit'
      assert_select 'a[href=?]', user_path(user), text: 'Delete', method: :delete
    end
    assert_difference 'User.count', -1 do
      delete user_path(@other_user)
    end
  end
  
  test "index including pagination" do
    log_in_as(@user)
    get users_path
    assert_redirected_to login_url
    @user.roles << Role.where(name: 'representative')
    assert_redirected_to login_url
    @user.roles << Role.where(name: 'admin')
    get users_path
    assert_response :success
    User.paginate(page: 1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end
end
