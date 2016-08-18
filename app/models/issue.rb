class Issue < ApplicationRecord

  # Model Relations
  belongs_to :user
  
  # Model Validations
  validates :user_id,     presence: true
  validates :title,       presence: true, length: { maximum: 100 }
  validates :description, presence: true, length: { maximum: 255 }
  
  # Enumerate Status field
  enum status: [ :open, :in_progress, :waiting_on_customer, :resolved, :closed ]
end
