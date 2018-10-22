class Message < ApplicationRecord
  has_many :comments

  validates :content, presence: true, length: { maximum: 140 }
end
