class User < ApplicationRecord
  has_many :characters, dependent: :destroy
  has_many :personas, dependent: :destroy
  has_many :conversations, through: :personas

  validates :email, presence: true, uniqueness: true
end
