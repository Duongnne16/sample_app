class Product < ApplicationRecord
  scope :recent, -> {order(created_at: :desc)}
end
