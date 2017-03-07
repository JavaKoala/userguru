class UsersController < ApplicationController
  before_action :logged_in_user,        only: [:index, :show, :edit, :update, :destroy]
  before_action :correct_or_admin_user, only: [:show, :edit, :update]
  before_action :admin_user,            only: [:index, :destroy]
  
  def index
    @users = User.order(sort_column(Issue.column_names, "name") + " " + sort_direction)
                 .paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    @issues = @user.issues.where.not(status: 'closed')
                          .order(sort_column(Issue.column_names, "title") + " " + sort_direction)
                          .paginate(page: params[:page])
    # need to assign @users variable for will_paginate
    @users = User.none().paginate(page: params[:page])
  end

  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    @user.auth_token = User.new_token
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end
  
  private
    
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, role_ids: [])
    end
    
    # Before filters

    # Confirms the correct user
    def correct_or_admin_user
      @user = User.find(params[:id]) 
      unless current_user?(@user) || admin_user?
        redirect_to(login_url)
      end
    end

end
