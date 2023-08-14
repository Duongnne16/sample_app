class User < ApplicationRecord
  has_secure_password

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  EMAIL_MIN_LENGTH = 20
  EMAIL_MAX_LENGTH = 255
  NAME_MAX_LENGTH = 10
  PASSWORD_MIN_LENGTH = 6
  MAX_BIRTHDAY_RANGE = 100

  before_save :downcase_email

  validates :email,
            presence: true,
            length: {minimum: EMAIL_MIN_LENGTH, maximum: EMAIL_MAX_LENGTH},
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}

  validates :name, presence: true, length: {maximum: NAME_MAX_LENGTH}

  validates :password, presence: true, length: {minimum: PASSWORD_MIN_LENGTH}

  validate :birthday_within_last_100_years

  private
  def downcase_email
    email.downcase!
  end

  def birthday_within_last_100_years
    return errors.add(:birthday, :blank) unless birthday.present?

    if birthday < MAX_BIRTHDAY_RANGE.years.ago.to_date || birthday > Time.zone.today
      errors.add(:birthday, :invalid_birthday_range)
    end
  end
end
