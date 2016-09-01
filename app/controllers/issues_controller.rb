class IssuesController < ApplicationController
  before_action :logged_in_user, only: [:new, :show, :create, :edit, :update, :destroy]
  before_action :admin_user,     only: :destroy
  
  def new
    @issue = Issue.new
  end
  
  def show
    @issue = Issue.find(params[:id])
  end
  
  def create
    @issue = Issue.new(issue_params)
    if @issue.save
      flash[:success] = "New issue created"
      redirect_to @current_user
    else
      render 'new'
    end
  end
  
  def edit
    @issue = Issue.find(params[:id])
  end
  
  def update
    @issue = Issue.find(params[:id])
    if @issue.update_attributes(issue_params)
      flash[:success] = "Issue updated"
      redirect_to issue_path(@issue)
    else
      render 'edit'
    end
  end
  
  def destroy
    Issue.find(params[:id]).destroy
    flash[:success] = "Issue deleted"
    redirect_to users_url
  end
  
  private
    
    def issue_params
      params.require(:issue).permit(:title, :description, :user_id, :status)
    end
end
