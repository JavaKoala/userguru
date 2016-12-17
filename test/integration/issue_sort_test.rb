require 'test_helper'

class IssueSortTest < ActionDispatch::IntegrationTest

  def setup

    # Set up users
    @representative_user = users(:representative)
    @customer1           = users(:customer1)
    add_roles_to_users

    # Set up issues
    @issue = issues(:one)
    add_user_issue
  end

  test 'issue table sort should include all search params for a representative' do
    log_in_as(@representative_user)
    get issues_path
    assert_select "a[href=?]", "/issues?direction=asc&sort=id", count: 1
    get issues_path, params: { search: 'LOL',
                               status: '',
                               assigned_user_id: '',
                               creator_user_id: '' }
    assert_response :success
    assert_select "td", /#{@issue.title}/, count: 1
    assert_select "a[href=?]", "/issues?assigned_user_id=&creator_user_id=&direction=asc&search=LOL&sort=id&status=", count: 1
  end

  test 'issue table sort should include all search params for a customer' do
    log_in_as(@customer1)
    get issues_path
    assert_select "a[href=?]", "/issues?direction=desc&sort=title", count: 1
    get issues_path, params: { search: 'LOL',
                               status: '' }
    assert_response :success
    assert_select "td", false, /#{@issue.title}/
    assert_select "a[href=?]", "/issues?direction=desc&search=LOL&sort=title&status=", count: 1
  end
end