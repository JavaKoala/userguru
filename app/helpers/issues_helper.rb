module IssuesHelper

  # returns the person who created the issues name
  def issue_creator_name(issue)
    User.find(issue.user_id).name
  end

  # returs true if the issue has an assinged user
  def has_assigned_user?(issue)
    !User.find_by(id: issue.user_issue.user_id).nil?
  end

  # returns the assigned users name or Not Assigned
  def assigned_user_name(issue)
    if has_assigned_user?(issue)
      User.find_by(id: issue.user_issue.user_id).name
    else
      "Not Assigned"
    end
  end
  
  # returns the assigned users id or nil
  def assigned_user_id(issue)
    if has_assigned_user?(issue)
      User.find_by(id: issue.user_issue.user_id).id
    else
      nil
    end
  end

  # returns true if the comment was created by the current user
  def user_comment?(user_id)
    @current_user.id == user_id
  end
  
  # returns the name of the person who created the comment
  def commenter_name(user_id)
    User.find(user_id).name
  end
end
