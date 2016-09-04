class ApplicationController < ActionController::Base
  helper_method :sort_column, :sort_direction
  protect_from_forgery with: :exception
  include SessionsHelper
  
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

    # Give a column to sort on, default title
    def sort_column
      Issue.column_names.include?(params[:sort]) ? params[:sort] : "title"
    end

    # Direction to sort on, default asc
    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
