module SessionsHelper
  # Logs in the given user
  def log_in(user)
    session[:user_id] = user.id
  end
  
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end
  
  # returns true if the given user is the current user
  def current_user?(user)
    user == current_user
  end
  
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # Uses the authorization in the api header to determine if the token exists for a user
  def api_user
    @api_user ||= User.find_by(auth_token: request.headers['authorization'])
  end

  def current_api_user?
    !api_user.nil?
  end

  # Returns true if the api user is internal, false if not
  def internal_api_user?
    current_api_user? && (api_user.roles.exists?(name: 'representative') ||
                          api_user.roles.exists?(name: 'admin'))
  end

  # Returns true if the api user is admin, false if not
  def admin_api_user?
    current_api_user? && api_user.roles.exists?(name: 'admin')
  end

  def logged_in?
    !current_user.nil?
  end
  
  # Forgets a persistent session.
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Logs out the current user.
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
  
  # Redirected to stored location (or to the default)
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:fowarding_url)
  end
  
  # Stores the URL trying to be accessed
  def store_location
    session[:fowarding_url] = request.url if request.get?
  end

  # Determines if the user is an internal user
  def internal_user?
    logged_in? && (current_user.roles.exists?(name: 'representative') || 
                   current_user.roles.exists?(name: 'admin'))
  end
  
  # Determines if the user is an admin user
  def admin_user?
    logged_in? && current_user.roles.exists?(name: 'admin')
  end
end
