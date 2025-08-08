class ConversationFact < ApplicationRecord
  belongs_to :conversation

  validates :conversation_id, presence: true
  validates :fact, presence: true
end
