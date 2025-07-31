class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  MAX_CONTENT_LENGTH = 140

  validates :content, presence: true, length: {maximum: MAX_CONTENT_LENGTH}
  validates :image,
            content_type: {in: %w(image/jpeg image/gif image/png),
                           message: I18n.t("microposts.image.invalid_format")},
            size:         {less_than: 5.megabytes,
                           message: I18n.t("microposts.image.too_large")}

  scope :newest, -> {order(created_at: :desc)}
end
