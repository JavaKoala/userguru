class Issue < ApplicationRecord

  # Model Relations
  belongs_to :user
  has_one :user_issue, dependent: :destroy
  has_many :comments, dependent: :destroy
  
  # Model Validations
  validates :user_id,     presence: true
  validates :title,       presence: true, length: { maximum: 100 }
  validates :description, presence: true, length: { maximum: 255 }
  
  # Enumerate Status field
  enum status: [ :open, :in_progress, :waiting_on_customer, :resolved, :closed ]

  # Find the issues for a given user_id
  scope :user_assigned_issues, ->(assigned_user_id) { joins("INNER JOIN user_issues ON issues.id = user_issues.issue_id AND
                                                                                       user_issues.user_id = #{assigned_user_id}") if assigned_user_id.present? }
  # Find the issue title or description
  scope :find_title_or_description, ->(search) { where("title LIKE ? OR description LIKE ?", "%#{search}%", "%#{search}%") if search.present? }

  # Find the issues with a given status
  scope :find_issues_with_status, ->(status) { where("status = ?", Issue.statuses[status]) if status.present? }

  # Find the issues created by a given user
  scope :find_issues_created_by_user, ->(creator_user_id) { where("issues.user_id = ?", "#{creator_user_id}") if creator_user_id.present? }

  # Search for issues
  def self.search(issue_search)
    # First find issues for external users
    if issue_search.has_key?(:user_id)
      find_title_or_description(issue_search[:search_params][:search]).find_issues_with_status(issue_search[:search_params][:status])
                                                                      .where("user_id = ?", "#{issue_search[:user_id]}")
    # Next return all the unassigned issues if no search is entered
    elsif issue_search[:search_params].empty?
      left_outer_joins(:user_issue).where(:user_issues => { :user_id => nil })
    # Finally return the internal user search
    else
      user_assigned_issues(issue_search[:search_params][:assigned_user_id]).find_title_or_description(issue_search[:search_params][:search])
                                                                           .find_issues_with_status(issue_search[:search_params][:status])
                                                                           .find_issues_created_by_user(issue_search[:search_params][:creator_user_id])
    end
  end
end
