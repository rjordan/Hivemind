class CharacterFact < ApplicationRecord
  belongs_to :character

  validates :character_id, presence: true
  validates :fact, presence: true
end
