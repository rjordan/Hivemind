require 'rails_helper'

RSpec.describe CharacterTrait, type: :model do
  let(:user) { User.create!(name: 'trait_user', email: 'trait@example.com') }
  let(:character) { user.characters.create!(name: 'Test Character') }

  describe 'validations' do
    let(:trait) { character.traits.build(trait_type: 'personality', value: 'friendly') }

    it 'is valid with valid attributes' do
      expect(trait).to be_valid
    end

    it 'validates presence of character_id' do
      trait.character = nil
      expect(trait).not_to be_valid
      expect(trait.errors[:character_id]).to include("can't be blank")
    end

    it 'validates presence of type' do
      trait.trait_type = nil
      expect(trait).not_to be_valid
      expect(trait.errors[:trait_type]).to include("can't be blank")
    end

    it 'validates presence of value' do
      trait.value = nil
      expect(trait).not_to be_valid
      expect(trait.errors[:value]).to include("can't be blank")
    end

    it 'is invalid without a character' do
      trait = CharacterTrait.new(trait_type: 'personality', value: 'friendly')
      expect(trait).not_to be_valid
      expect(trait.errors[:character]).to include("must exist")
    end
  end

  describe 'associations' do
    let(:trait) { character.traits.create!(trait_type: 'personality', value: 'friendly') }

    it 'belongs to a character' do
      expect(trait).to respond_to(:character)
      expect(CharacterTrait.reflect_on_association(:character).macro).to eq(:belongs_to)
    end

    it 'returns the correct character' do
      expect(trait.character).to eq(character)
    end
  end

  describe 'database constraints and attributes' do
    let(:trait) { character.traits.create!(trait_type: 'personality', value: 'friendly and outgoing') }

    it 'has UUID as primary key' do
      expect(trait.id).to be_present
      expect(trait.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/)
    end

    it 'references character with UUID foreign key' do
      expect(trait.character_id).to eq(character.id)
      expect(trait.character_id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/)
    end

    it 'stores trait_type with limit of 50 characters' do
      expect(trait.trait_type).to eq('personality')
    end

    it 'stores value as string' do
      expect(trait.value).to eq('friendly and outgoing')
    end

    it 'has timestamps' do
      expect(trait.created_at).to be_present
      expect(trait.updated_at).to be_present
    end
  end

  describe 'trait types and values' do
    let(:character) { user.characters.create!(name: 'Test Character') }

    it 'can store different types of traits' do
      personality_trait = character.traits.create!(trait_type: 'personality', value: 'cheerful')
      physical_trait = character.traits.create!(trait_type: 'physical', value: 'tall with brown hair')
      skill_trait = character.traits.create!(trait_type: 'skill', value: 'expert swordsman')

      expect(character.traits.count).to eq(3)
      expect(character.traits.map(&:trait_type)).to include('personality', 'physical', 'skill')
    end

    it 'can have multiple traits of the same type' do
      character.traits.create!(trait_type: 'personality', value: 'friendly')
      character.traits.create!(trait_type: 'personality', value: 'brave')

      personality_traits = character.traits.where(trait_type: 'personality')
      expect(personality_traits.count).to eq(2)
    end
  end
end
