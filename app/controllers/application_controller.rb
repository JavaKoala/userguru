class ApplicationController < ActionController::Base
  helper_method :sort_column, :sort_direction
  protect_from_forgery with: :exception
  include SessionsHelper
  include SettingsHelper
  
  private

    # Confirms a logged-in user
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in"
        redirect_to login_url
      end
    end

    # Confirms an admin user
    def admin_user
      unless admin_user?
        redirect_to login_url
      end
    end

    # Confirms an internal user
    def internal_user
      unless internal_user?
        redirect_to login_url
      end
    end

    # Confirms an api user
    def current_api_user
      unless current_api_user?
        render json: { errors: "Not authenticated" },
               status: :unauthorized
      end
    end

    # Give a column to sort on
    def sort_column(columns, default)
      columns.include?(params[:sort]) ? params[:sort] : default
    end

    # Direction to sort on, default asc
    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
