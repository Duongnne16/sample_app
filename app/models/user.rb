class User < ApplicationRecord
  has_secure_password
  has_many :microposts, dependent: :destroy

  PASSWORD_RESET_EXPIRATION_HOURS = 2

  USER_PARAMS = %i(
    name
    email
    birthday
    gender
    password
    password_confirmation
  ).freeze

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  EMAIL_MIN_LENGTH = 10
  EMAIL_MAX_LENGTH = 255
  NAME_MAX_LENGTH = 10
  PASSWORD_MIN_LENGTH = 6
  MAX_BIRTHDAY_RANGE = 100
  enum gender: {female: 0, male: 1, other: 2}

  before_save :downcase_email
  before_create :create_activation_digest

  validates :email,
            presence: true,
            length: {minimum: EMAIL_MIN_LENGTH, maximum: EMAIL_MAX_LENGTH},
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}
  validates :name, presence: true, length: {maximum: NAME_MAX_LENGTH}
  validates :password,
            presence: true,
            length: {minimum: PASSWORD_MIN_LENGTH},
            allow_nil: true
  validates :gender, presence: true

  validate :birthday_within_last_100_years

  attr_accessor :remember_token, :activation_token, :reset_token

  scope :ordered, -> {order(:id)}

  class << self
    # Returns the hash digest of the given string.
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create(string, cost:)
    end

    # Returns a random token.
    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_column(:remember_digest, User.digest(remember_token))
  end

  # Forgets a user.
  def forget
    update_column(:remember_digest, nil)
  end

  # Activeates the account.
  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false if digest.nil?

    BCrypt::Password.new(digest).is_password? token
  end

  def password_reset_expired?
    reset_send_at < PASSWORD_RESET_EXPIRATION_HOURS.hours.ago
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns reset_digest: User.digest(reset_token),
                   reset_send_at: Time.zone.now
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_resets(self).deliver_now
  end

  def feed
    microposts.order(created_at: :desc)
  end

  private
  def downcase_email
    email.downcase!
  end

  # Creates and assigns the activation token and digest.
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

  def birthday_within_last_100_years
    return errors.add(:birthday, :blank) if birthday.blank?

    if birthday < MAX_BIRTHDAY_RANGE.years.ago.to_date ||
       birthday > Time.zone.today
      errors.add(:birthday, :invalid_birthday_range)
    end
  end
end
