class Api::V1::SessionsController < ApplicationController
  respond_to :json

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password]) && user.roles.exists?
      user.auth_token = User.new_token
      user.save!
      render json: user, :only => [:auth_token]
    else
      render json: { errors: "Invalid email or password" }, status: 401
    end
  end

end
