class Api::V1::CommentsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :current_api_user, only: :create
  before_action :internal_or_issue_creator, only: :create
  respond_to :json

  def create
    @comment = Comment.new(comment_params)
    @comment.user_id = api_user.id
    @issue = Issue.find(comment_params[:issue_id])
    if @comment.save && !@issue.nil?
      render :json => @issue, status: 201
    else
      render json: { errors: "Bad Request" }, status: 400
    end
  end

  private

    def comment_params
      params.permit(:text, :issue_id)
    end

    # Non-existant issues return a 404 
    # Unauthorized issues should return a 401
    def internal_or_issue_creator
      if Issue.find_by(id: comment_params[:issue_id]).nil?
        render json: { errors: "Not Found" }, status: 404
      else
        @issue = api_user.issues.find_by(id: params[:issue_id])
        if (@issue.nil? && !internal_api_user?)
          render json: { errors: "Invalid issue" }, status: 401
        end
      end
    end

end
