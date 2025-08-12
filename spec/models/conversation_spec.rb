require 'rails_helper'

RSpec.describe Conversation, type: :model do
  let(:user) { User.create!(name: 'conv_user', email: 'conv@example.com') }
  let(:persona) { user.personas.create!(name: 'Test Persona', description: 'A test persona description') }

  describe 'validations' do
    let(:conversation) { Conversation.new(title: 'Test Conversation', persona: persona, scenario: 'Test scenario', conversation_model: 'llama3.2') }

    it 'is valid with valid attributes' do
      expect(conversation).to be_valid
    end

    it 'validates presence of persona_id' do
      conversation.persona = nil
      expect(conversation).not_to be_valid
      expect(conversation.errors[:persona_id]).to include("can't be blank")
    end

    it 'validates presence of title' do
      conversation.title = nil
      expect(conversation).not_to be_valid
      expect(conversation.errors[:title]).to include("can't be blank")
    end

    it 'is invalid without a persona' do
      conversation = Conversation.new(title: 'Test Conversation', scenario: 'Test scenario', conversation_model: 'llama3.2')
      expect(conversation).not_to be_valid
      expect(conversation.errors[:persona]).to include("must exist")
    end
  end

  describe 'associations' do
    let(:conversation) { Conversation.create!(title: 'Test Conversation', persona: persona, scenario: 'Test scenario', conversation_model: 'llama3.2') }
    let(:character) { user.characters.create!(name: 'Test Character') }

    it 'belongs to a persona' do
      expect(conversation).to respond_to(:persona)
      expect(Conversation.reflect_on_association(:persona).macro).to eq(:belongs_to)
    end

    it 'has and belongs to many characters' do
      expect(conversation).to respond_to(:characters)
      expect(Conversation.reflect_on_association(:characters).macro).to eq(:has_many)
    end

    it 'has many conversation facts' do
      expect(conversation).to respond_to(:conversation_facts)
      expect(Conversation.reflect_on_association(:conversation_facts).macro).to eq(:has_many)
    end

    it 'destroys dependent conversation facts when conversation is deleted' do
      fact = conversation.conversation_facts.create!(fact: 'Test fact')
      expect { conversation.destroy }.to change { ConversationFact.count }.by(-1)
    end

    it 'can be associated with characters' do
      conversation.characters << character
      expect(conversation.characters).to include(character)
      expect(character.conversations).to include(conversation)
    end

    it 'returns the correct persona' do
      expect(conversation.persona).to eq(persona)
    end
  end

  describe 'database constraints and attributes' do
    let(:conversation) do
      Conversation.create!(
        title: 'Test Conversation',
        persona: persona,
        tags: ['tag1', 'tag2'],
        assistant: false,
        scenario: 'A test scenario',
        initial_message: 'Hello, this is the initial message',
        conversation_model: 'llama3.2'
      )
    end

    it 'has UUID as primary key' do
      expect(conversation.id).to be_present
      expect(conversation.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/)
    end

    it 'references persona with UUID foreign key' do
      expect(conversation.persona_id).to eq(persona.id)
      expect(conversation.persona_id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/)
    end

    it 'supports tags as an array' do
      expect(conversation.tags).to eq(['tag1', 'tag2'])
      expect(conversation.tags).to be_an(Array)
    end

    it 'has default empty array for tags' do
      simple_conversation = Conversation.create!(title: 'Simple Conversation', persona: persona, scenario: 'Simple scenario', conversation_model: 'llama3.2')
      expect(simple_conversation.tags).to eq([])
    end

    it 'has default true for assistant flag' do
      simple_conversation = Conversation.create!(title: 'Simple Conversation', persona: persona, scenario: 'Simple scenario', conversation_model: 'llama3.2')
      expect(simple_conversation.assistant).to be_truthy
    end

    it 'can set assistant flag to false' do
      expect(conversation.assistant).to be_falsey
    end

    it 'requires scenario' do
      expect(conversation.scenario).to eq('A test scenario')
    end

    it 'allows initial_message to be nil' do
      simple_conversation = Conversation.create!(title: 'Simple Conversation', persona: persona, scenario: 'Simple scenario', conversation_model: 'llama3.2')
      expect(simple_conversation.initial_message).to be_nil
    end

    it 'can set initial_message' do
      expect(conversation.initial_message).to eq('Hello, this is the initial message')
    end

    it 'has timestamps' do
      expect(conversation.created_at).to be_present
      expect(conversation.updated_at).to be_present
    end
  end

  describe 'many-to-many relationship with characters' do
    let(:conversation) { Conversation.create!(title: 'Test Conversation', persona: persona, scenario: 'Test scenario', conversation_model: 'llama3.2') }
    let(:character1) { user.characters.create!(name: 'Character 1') }
    let(:character2) { user.characters.create!(name: 'Character 2') }

    it 'can have multiple characters' do
      conversation.characters = [character1, character2]
      expect(conversation.characters.count).to eq(2)
      expect(conversation.characters).to include(character1, character2)
    end

    it 'maintains unique associations' do
      conversation.characters << character1
      # The database constraint should prevent duplicate associations
      expect {
        conversation.characters << character1  # Try to add same character again
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
