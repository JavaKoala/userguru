class Setting < ApplicationRecord

  # Model Validations
  validates :name, presence: true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :value, format: { with: VALID_EMAIL_REGEX },
                    if: :email_setting?,
                    allow_blank: true

  def email_setting?
    name == "default_email"
  end
end