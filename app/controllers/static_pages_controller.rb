class StaticPagesController < ApplicationController
  def home
    if logged_in?
      if internal_user?
        @issues = Issue.joins(:user_issue).where(user_issues: { user_id: current_user.id })
                                          .where.not(status: 'closed')
                                          .order(sort_column + " " + sort_direction)
                                          .paginate(page: params[:page])
      else
        @issues = current_user.issues.where.not(status: 'closed')
                                     .order(sort_column + " " + sort_direction)
                                     .paginate(page: params[:page])
      end
      # need to assign @static_pages for will_paginate
      @static_pages = Issue.none().paginate(page: params[:page])
    end
  end

  def help
  end
end
