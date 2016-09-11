module IssuesHelper

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
end
