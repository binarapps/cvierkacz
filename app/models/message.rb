class Message < ApplicationRecord
  belongs_to :user
  has_many :comments

  validates :content, presence: true, length: { maximum: 140 }

  paginates_per 3

  has_one_attached :picture
end
