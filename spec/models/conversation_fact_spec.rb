require 'rails_helper'

RSpec.describe ConversationFact, type: :model do
  let(:user) { User.create!(name: 'fact_user', email: 'fact@example.com') }
  let(:persona) { user.personas.create!(name: 'Test Persona', description: 'A test persona description') }
  let(:conversation) { Conversation.create!(title: 'Test Conversation', persona: persona, scenario: 'Test scenario', conversation_model: 'llama3.2') }

  describe 'validations' do
    let(:fact) { conversation.conversation_facts.build(fact: 'The character likes pizza') }

    it 'is valid with valid attributes' do
      expect(fact).to be_valid
    end

    it 'validates presence of conversation_id' do
      fact.conversation = nil
      expect(fact).not_to be_valid
      expect(fact.errors[:conversation_id]).to include("can't be blank")
    end

    it 'validates presence of fact' do
      fact.fact = nil
      expect(fact).not_to be_valid
      expect(fact.errors[:fact]).to include("can't be blank")
    end

    it 'is invalid without a conversation' do
      fact = ConversationFact.new(fact: 'The character likes pizza')
      expect(fact).not_to be_valid
      expect(fact.errors[:conversation]).to include("must exist")
    end
  end

  describe 'associations' do
    let(:fact) { conversation.conversation_facts.create!(fact: 'The character likes pizza') }

    it 'belongs to a conversation' do
      expect(fact).to respond_to(:conversation)
      expect(ConversationFact.reflect_on_association(:conversation).macro).to eq(:belongs_to)
    end

    it 'returns the correct conversation' do
      expect(fact.conversation).to eq(conversation)
    end
  end

  describe 'database constraints and attributes' do
    let(:fact) { conversation.conversation_facts.create!(fact: 'This is a detailed fact about the conversation context and character preferences') }

    it 'has UUID as primary key' do
      expect(fact.id).to be_present
      expect(fact.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/)
    end

    it 'references conversation with UUID foreign key' do
      expect(fact.conversation_id).to eq(conversation.id)
      expect(fact.conversation_id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/)
    end

    it 'stores fact as string' do
      expect(fact.fact).to eq('This is a detailed fact about the conversation context and character preferences')
    end

    it 'has timestamps' do
      expect(fact.created_at).to be_present
      expect(fact.updated_at).to be_present
    end
  end

  describe 'conversation facts functionality' do
    let(:conversation) { Conversation.create!(title: 'Test Conversation', persona: persona, scenario: 'Test scenario', conversation_model: 'llama3.2') }

    it 'can store multiple facts for a conversation' do
      fact1 = conversation.conversation_facts.create!(fact: 'Character likes tea')
      fact2 = conversation.conversation_facts.create!(fact: 'Character is afraid of heights')
      fact3 = conversation.conversation_facts.create!(fact: 'Character has a pet cat named Whiskers')

      expect(conversation.conversation_facts.count).to eq(3)
      expect(conversation.conversation_facts.pluck(:fact)).to include(
        'Character likes tea',
        'Character is afraid of heights',
        'Character has a pet cat named Whiskers'
      )
    end

    it 'can retrieve facts in chronological order' do
      # Create facts with slight delays to ensure different timestamps
      fact1 = conversation.conversation_facts.create!(fact: 'First fact')
      sleep(0.001)
      fact2 = conversation.conversation_facts.create!(fact: 'Second fact')
      sleep(0.001)
      fact3 = conversation.conversation_facts.create!(fact: 'Third fact')

      facts_by_creation = conversation.conversation_facts.order(:created_at)
      expect(facts_by_creation.map(&:fact)).to eq(['First fact', 'Second fact', 'Third fact'])
    end

    it 'allows updating facts' do
      fact = conversation.conversation_facts.create!(fact: 'Original fact')
      fact.update!(fact: 'Updated fact')

      expect(fact.reload.fact).to eq('Updated fact')
    end
  end

  describe 'cascading deletes' do
    let(:fact) { conversation.conversation_facts.create!(fact: 'Test fact') }

    it 'is deleted when parent conversation is deleted' do
      fact_id = fact.id
      conversation.destroy

      expect(ConversationFact.find_by(id: fact_id)).to be_nil
    end
  end
end
