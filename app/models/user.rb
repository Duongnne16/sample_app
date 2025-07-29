class User < ApplicationRecord
  has_secure_password

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

  attr_accessor :remember_token

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

  def authenticated? remember_token
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  private
  def downcase_email
    email.downcase!
  end

  def birthday_within_last_100_years
    return errors.add(:birthday, :blank) if birthday.blank?

    if birthday < MAX_BIRTHDAY_RANGE.years.ago.to_date ||
       birthday > Time.zone.today
      errors.add(:birthday, :invalid_birthday_range)
    end
  end
end
