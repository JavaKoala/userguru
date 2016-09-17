class StaticPagesController < ApplicationController
  def home
    if logged_in?
      if internal_user?
        @issues = Issue.joins(:user_issue).where(user_issues: { user_id: current_user.id })
                                          .where.not(status: 'closed')
                                          .order(sort_column + " " + sort_direction)
      else
        @issues = current_user.issues.order(sort_column + " " + sort_direction)
      end
    end
  end

  def help
  end
end
