class IssuesController < ApplicationController
  before_action :logged_in_user,            only: [:index, :new, :show, :create, :edit, :update, :destroy]
  before_action :internal_or_issue_creator, only: [:show, :edit, :update]
  before_action :admin_user,                only: :destroy

  def index
    # If the user is not internal then we need to add the user_id to the search so that
    # we only look for that user's issues
    if internal_user?
      issue_search = { search_params: issue_search_params }
    else
      issue_search = { search_params: issue_search_params, user_id: current_user.id }
    end
    @issues = Issue.search(issue_search).order(sort_column + " " + sort_direction)
                                        .paginate(page: params[:page])
  end

  def new
    @issue = Issue.new
  end
  
  def show
    @issue = Issue.find(params[:id])
    @issue_comments = Comment.where(issue_id: @issue.id)
    @comment = Comment.new
  end
  
  def create
    @issue = Issue.new(issue_params)
    @issue.user_issue = UserIssue.new
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
    @userissue = UserIssue.find(@issue.user_issue.id)
    if @issue.update_attributes(issue_params)
      if internal_user?
        @userissue.update_attributes(issue_id: @issue.id, user_id: params[:user_issue][:assigned_user])
      end
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
    
    def user_issue_params
      params.require(:user_issue).pertmit(:assigned_user)
    end

    def issue_search_params
      params.permit(:search, :status, :assigned_user_id, :creator_user_id)
    end

    def internal_or_issue_creator
      @issue = current_user.issues.find_by(id: params[:id])
      redirect_to root_url if (@issue.nil? && !internal_user?)
    end
end
