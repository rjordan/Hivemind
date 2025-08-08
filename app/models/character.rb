class Character < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :conversations
  has_many :traits, class_name: 'CharacterTrait', dependent: :destroy

  validates :name, presence: true #, uniqueness: { scope: :user_id }
end
