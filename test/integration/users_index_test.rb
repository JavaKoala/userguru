require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:one)
    @user.roles << Role.where(name: 'customer')
  end
  
  test "index including pagination" do
    log_in_as(@user)
    get users_path
    assert_redirected_to login_url
    @user.roles << Role.where(name: 'representative')
    get users_path
    assert_response :success
    User.paginate(page: 1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end
end
