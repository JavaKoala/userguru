ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def is_logged_in?
    !session[:user_id].nil?
  end
  
  # Logs in as a test user
  def log_in_as(user, options = {})
    password    = options[:password]    || 'password'
    remember_me = options[:remember_me] || '1'
    if integration_test?
      post login_path, params: { session: { email: user.email,
                                            password: password,
                                            remember_me: remember_me } }
    else
      session[:user_id] = user.id
    end
  end

  def add_roles_to_users
    users(:admin_user).roles << Role.where(name: 'admin')
    users(:customer1).roles  << Role.where(name: 'customer')
    users(:customer2).roles  << Role.where(name: 'customer')
  end
  
  private
  
    # Returns true inside an integration test
    def integration_test?
      defined?(post_via_redirect)
    end
end
