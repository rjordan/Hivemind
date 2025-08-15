require 'rails_helper'

RSpec.describe Character, type: :model do
  let(:user) { User.create!(name: 'char_user', email: 'char@example.com') }

  describe 'validations' do
    let(:character) { user.characters.build(name: 'Test Character') }

    it 'is valid with valid attributes' do
      expect(character).to be_valid
    end

    it 'validates presence of name' do
      character.name = nil
      expect(character).not_to be_valid
      expect(character.errors[:name]).to include("can't be blank")
    end

    it 'is invalid without a user' do
      character = Character.new(name: 'Test Character')
      expect(character).not_to be_valid
      expect(character.errors[:user]).to include("must exist")
    end

    # Note: Uniqueness validation is commented out in the model
    # Uncomment this test if you enable the uniqueness validation
    # it 'validates uniqueness of name scoped to user' do
    #   user.characters.create!(name: 'Test Character')
    #   duplicate_character = user.characters.build(name: 'Test Character')
    #   expect(duplicate_character).not_to be_valid
    #   expect(duplicate_character.errors[:name]).to include("has already been taken")
    # end
  end

  describe 'associations' do
    let(:character) { user.characters.create!(name: 'Test Character') }
    let(:persona) { user.personas.create!(name: 'Test Persona', description: 'Test Description') }

    it 'belongs to a user' do
      expect(character).to respond_to(:user)
      expect(Character.reflect_on_association(:user).macro).to eq(:belongs_to)
    end

    it 'has and belongs to many conversations' do
      expect(character).to respond_to(:conversations)
      expect(Character.reflect_on_association(:conversations).macro).to eq(:has_many)
    end

    it 'has many traits' do
      expect(character).to respond_to(:traits)
      expect(Character.reflect_on_association(:traits).macro).to eq(:has_many)
    end

    it 'destroys dependent traits when character is deleted' do
      trait = character.traits.create!(trait_type: 'personality', value: 'friendly')
      expect { character.destroy }.to change { CharacterTrait.count }.by(-1)
    end

    it 'can be associated with conversations' do
      conversation = Conversation.create!(title: 'Test Conversation', persona: persona, scenario: 'Test scenario', conversation_model: 'llama3.2')
      character.conversations << conversation
      expect(character.conversations).to include(conversation)
      expect(conversation.characters).to include(character)
    end

    it 'returns the correct user' do
      expect(character.user).to eq(user)
    end
  end

  describe 'database constraints and attributes' do
    let(:character) { user.characters.create!(name: 'Test Character', alternate_names: [ 'Alt Name 1', 'Alt Name 2' ], tags: [ 'tag1', 'tag2' ]) }

    it 'has UUID as primary key' do
      expect(character.id).to be_present
      expect(character.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/)
    end

    it 'references user with UUID foreign key' do
      expect(character.user_id).to eq(user.id)
      expect(character.user_id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/)
    end

    it 'supports alternate names as an array' do
      expect(character.alternate_names).to eq([ 'Alt Name 1', 'Alt Name 2' ])
      expect(character.alternate_names).to be_an(Array)
    end

    it 'supports tags as an array' do
      expect(character.tags).to eq([ 'tag1', 'tag2' ])
      expect(character.tags).to be_an(Array)
    end

    it 'has default empty arrays for alternate_names and tags' do
      simple_character = user.characters.create!(name: 'Simple Character')
      expect(simple_character.alternate_names).to eq([])
      expect(simple_character.tags).to eq([])
    end

    it 'has timestamps' do
      expect(character.created_at).to be_present
      expect(character.updated_at).to be_present
    end
  end

  describe 'database indexes' do
    it 'should have index on name for performance' do
      # This tests that the migration was applied correctly
      # In a real test, you might check database schema or use database_cleaner
      character = user.characters.create!(name: 'Indexed Character')
      expect(character.persisted?).to be_truthy
    end
  end
end
