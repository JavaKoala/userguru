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
  def self.search(title, status)
    if title
      where("title LIKE ? AND status = ?", "%#{title}%", Issue.statuses[status] )
    else
      left_outer_joins(:user_issue).where(:user_issues => { :user_id => nil })
    end
  end
end
