class User < ApplicationRecord

  attr_accessor :remember_token, :activation_token, :reset_token
  
  # before save
  before_save { email.downcase! }
  
  # before create
  before_create :create_activation_digest
  before_create { self.auth_token = User.new_auth_token }
  
  # Model relations
  has_many :user_roles, dependent: :destroy
  has_many :roles, :through => :user_roles
  has_many :issues, dependent: :destroy
  has_many :user_issues, dependent: :nullify
  has_many :comments, dependent: :destroy
  
  # Model validations
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, length: { minimum: 6 }, allow_blank: true
  validates :auth_token, uniqueness: true

  # Returns the has digest of the given string
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
  
  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Returns a random auth token
  def User.new_auth_token
    SecureRandom.urlsafe_base64(64)
  end

  # Remembers a user in the database for use in persistent sessions
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Returns true if the given token matches the digest
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  
  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  # Activates an account
  def activate
    update_attribute(:activated, true)
    update_attribute(:activated_at, Time.now)
    User.admin_users.each do |admin_user| 
      UserMailer.new_user_activated(self, admin_user).deliver_now
    end
  end

  # Send the activation email
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.now)
  end

  # Sends password reset email
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # Returns a collection of the admin users
  scope :admin_users, -> { joins("INNER JOIN user_roles ON users.id = user_roles.user_id
                                  INNER JOIN roles ON user_roles.role_id = roles.id").
                           where("roles.name = ?", "admin") }

  private
  
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end

end
