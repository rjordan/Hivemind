class Conversation < ApplicationRecord
  belongs_to :persona
  has_many :character_conversations, dependent: :destroy
  has_many :characters, through: :character_conversations
  has_many :conversation_facts, dependent: :destroy

  validates :persona_id, presence: true
  validates :title, presence: true
end
