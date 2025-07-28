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
  validates :password, presence: true, length: {minimum: PASSWORD_MIN_LENGTH}
  validates :gender, presence: true

  validate :birthday_within_last_100_years

  # Returns the hash digest of the given string.
  def self.digest string
    cost = if ActiveModel::SecurePassword.min_cost
             BCrypt::Engine::MIN_COST
           else
             BCrypt::Engine.cost
           end
    BCrypt::Password.create(string, cost:)
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
