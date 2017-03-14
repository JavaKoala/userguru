class Api::V1::IssuesController < ApplicationController
  respond_to :json
  def show
    title = params[:title]
    @category = Issue.find_by(title: title)
    render :json => @category
  end
end
