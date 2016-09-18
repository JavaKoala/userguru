class Comment < ApplicationRecord

  # Model Relations
  belongs_to :issue
  belongs_to :user

  # Model Validations
  validates :issue_id, presence: true
  validates :user_id,  presence: true
  validates :text,     presence: true, length: { maximum: 255 }
end
