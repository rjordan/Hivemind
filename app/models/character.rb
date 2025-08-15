class Character < ApplicationRecord
  belongs_to :user
  has_many :character_conversations, dependent: :destroy
  has_many :conversations, through: :character_conversations
  has_many :traits, class_name: "CharacterTrait", dependent: :destroy

  validates :name, presence: true # , uniqueness: { scope: :user_id }
  validates :default_model, presence: true
end
