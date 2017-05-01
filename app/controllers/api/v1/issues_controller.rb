class Api::V1::IssuesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :current_api_user, only: [:index, :show, :create]
  before_action :internal_or_issue_creator, only: :show
  respond_to :json

  def index
    if internal_api_user?
      issue_search = { search_params: issue_search_params }
    else
      issue_search = { search_params: issue_search_params, user_id: api_user.id }
    end
    @issues = Issue.search(issue_search)
    render :json => @issues, each_serializer: IssueSearchSerializer
  end

  def show
    @issue = Issue.find(params[:id])
    render :json => @issue
  end

  def create
    # Merging in the user_id because it is the user_id of the current user creating the issue
    @issue = Issue.new(issue_params.merge(user_id: api_user.id))
    @issue.user_issue = UserIssue.new
    if @issue.save
      render :json => @issue, status: 201
    else
      render json: { errors: "Bad Request" }, status: 400
    end
  end

  private

    def issue_params
      params.permit(:title, :description)
    end

    def issue_search_params
      params.permit(:search, :status)
    end

    # Invalid or unauthorized issues should return a 401
    def internal_or_issue_creator
      @issue = api_user.issues.find_by(id: params[:id])
      if (@issue.nil? && !internal_api_user?)
        render json: { errors: "Invalid issue" }, status: 401
      end
    end

end
