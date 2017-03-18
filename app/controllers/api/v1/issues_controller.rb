class Api::V1::IssuesController < ApplicationController
  respond_to :json

  def index
    issue_search = params[:title]
    @issues = Issue.find_by(title: issue_search)
    render :json => @issues
  end
end
