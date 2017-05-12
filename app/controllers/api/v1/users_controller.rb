class Api::V1::UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :current_api_user, only: :index
  respond_to :json

  def index
    # No one should be able to see anyone elses user info
    if api_user.email == params[:email]
      @user = User.find_by(email: params[:email])
      render json: @user, serializer: UserInfoSerializer
    else
      render json: { errors: "Bad Request" }, status: 400
    end
  end

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
