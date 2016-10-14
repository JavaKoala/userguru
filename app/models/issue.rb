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

  # Search for issues
  def self.search(search, status, assigned_user_id)
    print assigned_user_id
    if search
      if assigned_user_id != ''
        joins("INNER JOIN user_issues ON issues.id = user_issues.issue_id AND
                                                     user_issues.user_id = #{assigned_user_id}").
        where("(title LIKE ? OR description LIKE ?) AND status = ?", "%#{search}%", "%#{search}%", Issue.statuses[status] )
      else
        where("(title LIKE ? OR description LIKE ?) AND status = ?", "%#{search}%", "%#{search}%", Issue.statuses[status] )
      end
    else
      left_outer_joins(:user_issue).where(:user_issues => { :user_id => nil })
    end
  end
end
