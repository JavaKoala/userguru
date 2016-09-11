class UserIssue < ApplicationRecord
  belongs_to :issue
  has_one :user
  validates :issue_id, presence: true

end
