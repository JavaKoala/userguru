class Api::V1::IssuesController < ApplicationController
  before_action :current_api_user, only: :index
  respond_to :json

  def index
    if internal_api_user?
      issue_search = { search_params: issue_search_params }
    else
      issue_search = { search_params: issue_search_params, user_id: api_user.id }
    end
    @issues = Issue.search(issue_search)
    render :json => @issues
  end

  private

    def issue_search_params
      params.permit(:search, :status)
    end

end
