class CharacterTrait < ApplicationRecord
  belongs_to :character

  validates :character_id, presence: true
  validates :type, presence: true
  validates :value, presence: true
end
