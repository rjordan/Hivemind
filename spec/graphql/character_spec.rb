require 'rails_helper'

RSpec.describe HivemindSchema, type: :request do
  let(:user) { User.create!(name: "testuser", email: "test@example.com") }
  let(:context) { { current_user: user } }
  let(:variables) { {} }

  def exec_query(query_string, vars: variables)
    described_class.execute(query_string, variables: vars, context: context)
  end

  describe 'characters basic query' do
    let!(:char1) { user.characters.create!(name: 'Alpha', tags: %w[tag1], alternate_names: [], public: false) }
    let!(:char2) { user.characters.create!(name: 'Beta', tags: %w[tag2], alternate_names: [ 'B' ], public: true) }

    let(:query_string) do
      <<~GQL
        query {
          characters {
            edges {
              node {
                id
                name
                tags
                public
              }
            }
          }
        }
      GQL
    end

    it 'returns user characters ordered by name' do
      res = exec_query(query_string)
      expect(res['errors']).to be_nil
      names = res['data']['characters']['edges'].map { |e| e['node']['name'] }
      expect(names).to eq(%w[Alpha Beta])
    end
  end

  describe 'include_public argument' do
    let!(:other_user) { User.create!(name: 'other', email: 'other@example.com') }
    let!(:public_other_char) { other_user.characters.create!(name: 'PublicChar', public: true) }
    let!(:private_other_char) { other_user.characters.create!(name: 'PrivateChar', public: false) }

    let(:query_string) do
      <<~GQL
        query($inc: Boolean) {
          characters(includePublic: $inc) {
            edges { node { name public } }
          }
        }
      GQL
    end

    it 'excludes other users public chars by default' do
      res = exec_query(query_string, vars: { inc: false })
      names = res['data']['characters']['edges'].map { |e| e['node']['name'] }
      expect(names).not_to include('PublicChar')
    end

    it 'includes public characters from others when includePublic true' do
      res = exec_query(query_string, vars: { inc: true })
      names = res['data']['characters']['edges'].map { |e| e['node']['name'] }
      expect(names).to include('PublicChar')
      expect(names).not_to include('PrivateChar')
    end
  end

  describe 'traits and conversations eager loading' do
    let!(:character) { user.characters.create!(name: 'WithStuff') }
    let!(:trait) { character.traits.create!(trait_type: 'Personality', value: 'Very Brave') }
    let!(:persona) { user.personas.create!(name: 'Persona', description: 'Desc') }
    let!(:conversation) { persona.conversations.create!(title: 'Conv', scenario: 'Scen', conversation_model: 'llama3.2') }

    before do
      conversation.characters << character
    end

    let(:query_string) do
      <<~GQL
        query {
          characters {
            edges {
              node {
                name
                traits { traitType value }
                conversations { title }
              }
            }
          }
        }
      GQL
    end

    it 'returns nested traits and conversations' do
      res = exec_query(query_string)
      expect(res['errors']).to be_nil
      node = res['data']['characters']['edges'].first['node']
      expect(node['traits'].first).to match(
        "traitType" => 'Personality',
        "value" => 'Very Brave'
      )
      expect(node['conversations'].first['title']).to eq('Conv')
    end
  end

  describe 'authentication' do
    let(:query_string) { 'query { characters { edges { node { id } } } }' }

    it 'errors without current_user' do
      res = described_class.execute(query_string, variables: {}, context: {})
      expect(res['errors']).not_to be_nil
      expect(res['errors'].first['message']).to include('Authentication required')
    end
  end
end
