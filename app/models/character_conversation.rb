class CharacterConversation < ApplicationRecord
  belongs_to :character
  belongs_to :conversation
end
