class Conversation < ApplicationRecord
  belongs_to :persona
  has_and_belongs_to_many :characters
  has_many :conversation_facts, dependent: :destroy

  validates :persona_id, presence: true
  validates :title, presence: true
end
