class CommentsController < ApplicationController
  before_action :logged_in_user, only: :create
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  def create
    @comment = Comment.new(comment_params)
    @issue   = Issue.find(params[:issue_id])
    @comment.issue_id = @issue.id
    @comment.user_id  = @current_user.id
    if @comment.save
      flash[:success] = "Comment created!"
      redirect_to @issue
    else
      redirect_to @issue
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

    def comment_params
      params.require(:comment).permit(:text, :issue_id, :user_id)
    end

    def correct_user
      @comment = current_user.comments.find_by(id: params[:id])
      redirect_to root_url if @comment.nil?
    end
end
