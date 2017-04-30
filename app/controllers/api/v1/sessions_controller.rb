class Api::V1::SessionsController < ApplicationController
  respond_to :json

  def index
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticate(params[:password]) && user.roles.exists?
      user.auth_token = User.new_auth_token
      user.save!
      render json: user, serializer: UserAuthTokenSerializer
    else
      render json: { errors: "Invalid email or password" }, status: 401
    end
  end

end
