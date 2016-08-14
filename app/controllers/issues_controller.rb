class IssuesController < ApplicationController
  before_action :logged_in_user, only: [:new, :create, :destroy]
  
  def new
    @issue = Issue.new
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
  
  def destroy
  end
  
  private
    
    def issue_params
      params.require(:issue).permit(:title, :description, :user_id)
    end
end
