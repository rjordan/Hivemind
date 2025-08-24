class Character < ApplicationRecord
  belongs_to :user
  has_many :character_conversations, dependent: :destroy
  has_many :conversations, through: :character_conversations
  has_many :facts, class_name: "CharacterFact", dependent: :destroy

  validates :name, presence: true # , uniqueness: { scope: :user_id }
  validates :description, presence: true
  validates :default_model, presence: true
end
