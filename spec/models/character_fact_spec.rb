require 'rails_helper'

RSpec.describe CharacterFact, type: :model do
  let(:user) { User.create!(name: 'user', email: 'fact@example.com') }
  let(:character) { user.characters.create!(name: 'Test Character', description: "test") }

  describe 'validations' do
  let(:fact) { character.facts.build(fact: 'Test fact') }

    it 'is valid with valid attributes' do
      expect(fact).to be_valid
    end

    it 'validates presence of character_id' do
      fact.character = nil
      expect(fact).not_to be_valid
      expect(fact.errors[:character_id]).to include("can't be blank")
    end

    it 'validates presence of fact' do
      fact.fact = nil
      expect(fact).not_to be_valid
      expect(fact.errors[:fact]).to include("can't be blank")
    end

    it 'is invalid without a character' do
      fact.character = nil
      expect(fact).not_to be_valid
      expect(fact.errors[:character]).to include("must exist")
    end
  end

  describe 'associations' do
  let(:fact) { character.facts.create!(fact: 'friendly') }

    it 'belongs to a character' do
      expect(fact).to respond_to(:character)
      expect(CharacterFact.reflect_on_association(:character).macro).to eq(:belongs_to)
    end

    it 'returns the correct character' do
      expect(fact.character).to eq(character)
    end
  end

  describe 'database constraints and attributes' do
  let(:fact) { character.facts.create!(fact: 'friendly and outgoing') }

    it 'has primary key' do
      expect(fact.id).to be_present
    end

    it 'references character with foreign key' do
      expect(fact.character_id).to eq(character.id)
    end

    it 'stores fact as string' do
      expect(fact.fact).to eq('friendly and outgoing')
    end

    it 'has timestamps' do
      expect(fact.created_at).to be_present
      expect(fact.updated_at).to be_present
    end
  end

  describe 'fact types and values' do
  let(:character) { user.characters.create!(name: 'Test Character', description: 'A test character description') }

    it 'can store multiple facts for a character' do
      fact1 = character.facts.create!(fact: 'cheerful')
      fact2 = character.facts.create!(fact: 'tall with brown hair')
      fact3 = character.facts.create!(fact: 'expert swordsman')

      expect(character.facts.count).to eq(3)
      expect(character.facts.map(&:fact)).to include('cheerful', 'tall with brown hair', 'expert swordsman')
    end
  end
end
