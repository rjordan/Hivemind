class Persona < ApplicationRecord
  belongs_to :user
  has_many :conversations, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true
end
