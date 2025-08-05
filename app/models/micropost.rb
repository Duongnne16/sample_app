class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  VALID_IMAGE_CONTENT_TYPES = %w(image/jpeg image/png image/gif).freeze
  MAX_CONTENT_LENGTH = 140
  GRAVATAR_SIZE = 50
  IMAGE_RESIZE_LIMIT = [500, 500].freeze

  validates :content, presence: true, length: {maximum: MAX_CONTENT_LENGTH}
  validates :image,
            content_type: {in: VALID_IMAGE_CONTENT_TYPES,
                           message: I18n.t("microposts.image.invalid_format")},
            size:         {less_than: 5.megabytes,
                           message: I18n.t("microposts.image.too_large")}

  scope :recent, -> {order(created_at: :desc)}
  scope :newest, -> {order(created_at: :desc)}
end
