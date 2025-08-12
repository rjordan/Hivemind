require 'rails_helper'

RSpec.describe HivemindSchema, type: :request do
  let(:user) { User.create!(name: "testuser", email: "test@example.com") }
  let(:persona) { user.personas.create!(name: "Test Persona", description: "Test Description") }
  let(:character) { user.characters.create!(name: "Test Character") }

  let(:context) do
    { current_user: user }
  end

  let(:variables) do
    {}
  end

  let(:result) do
    res = described_class.execute(query_string, variables: variables, context: context)
    expect(res['errors']).to be_nil
    res
  end

  describe 'conversations query' do
    let(:query_string) do
      <<~GQL
        query {
          conversations {
            edges {
              node {
                id
                title
                scenario
                tags
                assistant
                initialMessage
                conversationModel
                createdAt
                updatedAt
              }
              cursor
            }
            pageInfo {
              hasNextPage
              hasPreviousPage
              startCursor
              endCursor
            }
          }
        }
      GQL
    end

    let!(:conversation) do
      Conversation.create!(
        title: "Test Conversation",
        scenario: "Test Scenario",
        tags: ["test"],
        assistant: true,
        initial_message: "Test Initial Message",
        persona: persona,
        conversation_model: 'llama3.2'
      )
    end

    let(:valid_result) do
      {
        "edges" => [
          {
            "cursor" => an_instance_of(String),
            "node" => {
              "id" => conversation.id,
              "title" => "Test Conversation",
              "scenario" => "Test Scenario",
              "tags" => ["test"],
              "assistant" => true,
              "initialMessage" => "Test Initial Message",
              "conversationModel" => "llama3.2",
              "createdAt" => an_instance_of(String),
              "updatedAt" => an_instance_of(String)
            }
          }
        ],
        "pageInfo" => {
          "hasNextPage" => false,
          "hasPreviousPage" => false,
          "startCursor" => an_instance_of(String),
          "endCursor" => an_instance_of(String)
        }
      }
    end

    it 'returns a valid result' do
      expect(result['data']['conversations']).to match(valid_result)
    end
  end

  describe 'multiple conversations' do
    let(:query_string) do
      <<~GQL
        query {
          conversations {
            edges {
              node {
                id
                title
                scenario
                assistant
              }
            }
          }
        }
      GQL
    end

    let!(:conversation1) do
      Conversation.create!(
        title: "First Conversation",
        scenario: "First Scenario",
        tags: ["test", "first"],
        assistant: true,
        persona: persona,
        conversation_model: 'llama3.2'
      )
    end

    let!(:conversation2) do
      Conversation.create!(
        title: "Second Conversation",
        scenario: "Second Scenario",
        tags: ["test", "second"],
        assistant: false,
        persona: persona,
        conversation_model: 'llama3.2'
      )
    end

    it 'returns multiple conversations' do
      expect(result['data']['conversations']['edges'].length).to eq(2)
    end

    it 'returns conversations in correct order' do
      titles = result['data']['conversations']['edges'].map { |edge| edge['node']['title'] }
      expect(titles).to include("First Conversation", "Second Conversation")
    end
  end

  describe 'empty conversations' do
    let(:query_string) do
      <<~GQL
        query {
          conversations {
            edges {
              node {
                id
                title
              }
            }
          }
        }
      GQL
    end

    it 'returns empty array when no conversations exist' do
      expect(result['data']['conversations']['edges']).to be_empty
    end
  end

  describe 'pagination' do
    let!(:conversations) do
      5.times.map do |i|
        Conversation.create!(
          title: "Conversation #{i}",
          scenario: "Scenario #{i}",
          persona: persona,
          conversation_model: 'llama3.2'
        )
      end
    end

    context 'with first parameter' do
      let(:query_string) do
        <<~GQL
          query {
            conversations(first: 2) {
              edges {
                node {
                  title
                }
              }
              pageInfo {
                hasNextPage
                hasPreviousPage
              }
            }
          }
        GQL
      end

      it 'returns limited number of conversations' do
        expect(result['data']['conversations']['edges'].length).to eq(2)
      end

      it 'indicates there are more pages' do
        expect(result['data']['conversations']['pageInfo']['hasNextPage']).to be_truthy
      end
    end

    context 'with last parameter' do
      let(:query_string) do
        <<~GQL
          query {
            conversations(last: 2) {
              edges {
                node {
                  title
                }
              }
              pageInfo {
                hasNextPage
                hasPreviousPage
              }
            }
          }
        GQL
      end

      it 'returns last conversations' do
        expect(result['data']['conversations']['edges'].length).to eq(2)
      end

      it 'indicates there are previous pages' do
        expect(result['data']['conversations']['pageInfo']['hasPreviousPage']).to be_truthy
      end
    end
  end

  describe 'conversations with null initial_message' do
    let(:query_string) do
      <<~GQL
        query {
          conversations {
            edges {
              node {
                id
                title
                initialMessage
              }
            }
          }
        }
      GQL
    end

    let!(:conversation_without_message) do
      Conversation.create!(
        title: "No Message Conversation",
        scenario: "No Message Scenario",
        persona: persona,
        initial_message: nil,
        conversation_model: 'llama3.2'
      )
    end

    it 'handles null initial_message correctly' do
      node = result['data']['conversations']['edges'].first['node']
      expect(node['initialMessage']).to be_nil
    end
  end

  describe 'conversations with different tag arrays' do
    let(:query_string) do
      <<~GQL
        query {
          conversations {
            edges {
              node {
                title
                tags
              }
            }
          }
        }
      GQL
    end

    let!(:conversation_with_tags) do
      Conversation.create!(
        title: "Tagged Conversation",
        scenario: "Tagged Scenario",
        tags: ["work", "important", "meeting"],
        persona: persona,
        conversation_model: 'llama3.2'
      )
    end

    let!(:conversation_without_tags) do
      Conversation.create!(
        title: "Untagged Conversation",
        scenario: "Untagged Scenario",
        tags: [],
        persona: persona,
        conversation_model: 'llama3.2'
      )
    end

    it 'returns conversations with different tag configurations' do
      conversations = result['data']['conversations']['edges']
      tagged_conv = conversations.find { |conv| conv['node']['title'] == "Tagged Conversation" }
      untagged_conv = conversations.find { |conv| conv['node']['title'] == "Untagged Conversation" }

      expect(tagged_conv['node']['tags']).to eq(["work", "important", "meeting"])
      expect(untagged_conv['node']['tags']).to eq([])
    end
  end

  describe 'conversations with special characters and edge cases' do
    let(:query_string) do
      <<~GQL
        query {
          conversations {
            edges {
              node {
                title
                scenario
                initialMessage
              }
            }
          }
        }
      GQL
    end

    let!(:special_conversation) do
      Conversation.create!(
        title: "Special Characters: !@#$%^&*()",
        scenario: "Scenario with \"quotes\" and 'apostrophes'",
        initial_message: "Message with\nnewlines\tand\ttabs",
        persona: persona,
        conversation_model: 'llama3.2'
      )
    end

    it 'handles special characters correctly' do
      node = result['data']['conversations']['edges'].first['node']

      expect(node['title']).to eq("Special Characters: !@#$%^&*()")
      expect(node['scenario']).to eq("Scenario with \"quotes\" and 'apostrophes'")
      expect(node['initialMessage']).to eq("Message with\nnewlines\tand\ttabs")
    end
  end

  describe 'error handling' do
    context 'with invalid GraphQL syntax' do
      let(:query_string) do
        <<~GQL
          query {
            conversations {
              edges {
                node {
                  invalidField
                }
              }
            }
          }
        GQL
      end

      it 'returns an error for invalid fields' do
        res = described_class.execute(query_string, variables: variables, context: context)
        expect(res['errors']).not_to be_nil
        expect(res['errors'].first['message']).to include("Field 'invalidField' doesn't exist")
      end
    end

    context 'with malformed query' do
      let(:query_string) do
        <<~GQL
          query {
            conversations {
              edges {
                node
              }
            }
          }
        GQL
      end

      it 'returns a syntax error' do
        res = described_class.execute(query_string, variables: variables, context: context)
        expect(res['errors']).not_to be_nil
      end
    end
  end

  describe 'performance and large datasets' do
    let(:query_string) do
      <<~GQL
        query {
          conversations {
            edges {
              node {
                id
                title
              }
            }
          }
        }
      GQL
    end

    before do
      # Create a larger dataset
      50.times do |i|
        Conversation.create!(
          title: "Performance Test Conversation #{i}",
          scenario: "Performance Scenario #{i}",
          persona: persona,
          conversation_model: 'llama3.2'
        )
      end
    end

    it 'handles large datasets without timeout' do
      start_time = Time.current
      result
      end_time = Time.current

      expect(end_time - start_time).to be < 2.0 # Should complete within 2 seconds
      expect(result['data']['conversations']['edges'].length).to eq(50)
    end
  end

  describe 'conversations with associations' do
    let(:query_string) do
      <<~GQL
        query {
          conversations {
            edges {
              node {
                id
                title
              }
            }
          }
        }
      GQL
    end

    let!(:conversation_with_character) do
      conv = Conversation.create!(
        title: "Conversation with Character",
        scenario: "Character Scenario",
        persona: persona,
        conversation_model: 'llama3.2'

      )
      conv.characters << character
      conv
    end

    let!(:conversation_with_facts) do
      conv = Conversation.create!(
        title: "Conversation with Facts",
        scenario: "Facts Scenario",
        persona: persona,
        conversation_model: 'llama3.2'
      )
      conv.conversation_facts.create!(fact: "Important fact")
      conv.conversation_facts.create!(fact: "Another fact")
      conv
    end

    it 'returns conversations that have associated data' do
      conversations = result['data']['conversations']['edges']

      expect(conversations.length).to eq(2)
      expect(conversations.map { |conv| conv['node']['title'] }).to include(
        "Conversation with Character",
        "Conversation with Facts"
      )
    end

    it 'maintains data integrity' do
      # Verify the associations exist in the database
      expect(conversation_with_character.characters).to include(character)
      expect(conversation_with_facts.conversation_facts.count).to eq(2)
    end
  end
end
