require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  
  def setup
    @customer1           = users(:customer1)
    @customer2           = users(:customer2)
    @representative_user = users(:representative)
    @admin_user          = users(:admin_user)
    add_roles_to_users
  end
  
  test "index as admin including pagination, edit and delete links" do
    log_in_as(@customer1)
    get users_path
    assert_redirected_to login_url
    delete logout_path
    follow_redirect!
    assert_not is_logged_in?
    log_in_as(@admin_user)
    get users_path
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      assert_select 'a[href=?]', edit_user_path(user), text: 'Edit'
      assert_select 'a[href=?]', user_path(user), text: 'Delete', method: :delete
    end
    assert_difference 'User.count', -1 do
      delete user_path(@customer2)
    end
  end
  
  test "index including pagination" do
    log_in_as(@representative_user)
    get users_path
    assert_redirected_to login_url
    delete logout_path
    follow_redirect!
    assert_not is_logged_in?
    log_in_as(@admin_user)
    get users_path
    assert_response :success
    User.paginate(page: 1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end
end
