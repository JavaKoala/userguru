class Api::V1::UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  respond_to :json

  def create
    @user = User.new(user_params)
    @user.auth_token = User.new_auth_token
    if @user.save
      @user.send_activation_email
      render json: { activation: "Please check your email to activate your account." }, status: 201
    else
      render json: { errors: "Bad Request" }, status: 400
    end
  end

  private

    def user_params
      params.permit(:name, :email, :password)
    end
end
