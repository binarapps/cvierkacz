class Comment < ApplicationRecord
  belongs_to :message

  validates :content, presence: true, length: { maximum: 140 }
end
