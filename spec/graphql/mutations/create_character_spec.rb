require 'rails_helper'

RSpec.describe Mutations::CreateCharacter, type: :request do
  let(:user) { User.create!(name: "testuser", email: "test@example.com") }
  let(:context) { { current_user: user } }
  let(:variables) { {} }

  def exec_mutation(query_string, vars: variables)
    HivemindSchema.execute(query_string, variables: vars, context: context)
  end

  describe '#resolve' do
    let(:mutation_string) do
      <<~GQL
        mutation CreateCharacter($input: CreateCharacterInput!) {
          createCharacter(input: $input) {
            character {
              id
              name
              description
              alternateNames
              tags
              public
              defaultModel
              createdAt
              updatedAt
              user {
                id
                name
              }
            }
            errors
          }
        }
      GQL
    end

    context 'with valid attributes' do
      let(:variables) do
        {
          input: {
            name: "Gandalf",
            description: "A wise wizard",
            alternateNames: [ "Mithrandir", "The Grey Pilgrim" ],
            tags: [ "wizard", "fantasy", "wise" ],
            public: true,
            defaultModel: "llama3.2"
          }
        }
      end

      it 'creates a character successfully' do
        expect {
          exec_mutation(mutation_string, vars: variables)
        }.to change(Character, :count).by(1)

        result = exec_mutation(mutation_string, vars: variables)
        expect(result['errors']).to be_nil

        character_data = result['data']['createCharacter']['character']
        expect(character_data['name']).to eq('Gandalf')
        expect(character_data['description']).to eq('A wise wizard')
        expect(character_data['alternateNames']).to eq([ 'Mithrandir', 'The Grey Pilgrim' ])
        expect(character_data['tags']).to eq([ 'wizard', 'fantasy', 'wise' ])
        expect(character_data['public']).to be true
        expect(character_data['defaultModel']).to eq('llama3.2')
        expect(character_data['user']['id']).to be_present
        expect(character_data['user']['name']).to eq('testuser')

        expect(result['data']['createCharacter']['errors']).to eq([])
      end

      it 'associates the character with the current user' do
        result = exec_mutation(mutation_string, vars: variables)
        character = Character.find(result['data']['createCharacter']['character']['id'])
        expect(character.user).to eq(user)
      end
    end

    context 'with minimal required attributes' do
      let(:variables) do
        {
          input: {
            name: "Simple Character",
            description: "A basic character"
          }
        }
      end

      it 'creates a character with default values' do
        result = exec_mutation(mutation_string, vars: variables)
        expect(result['errors']).to be_nil

        character_data = result['data']['createCharacter']['character']
        expect(character_data['name']).to eq('Simple Character')
        expect(character_data['description']).to eq('A basic character')
        expect(character_data['alternateNames']).to eq([])
        expect(character_data['tags']).to eq([])
        expect(character_data['public']).to be false
        expect(character_data['defaultModel']).to eq('llama3.2')

        expect(result['data']['createCharacter']['errors']).to eq([])
      end
    end

    context 'with invalid attributes' do
      context 'missing name' do
        let(:variables) do
          {
            input: {
              description: "A character without a name"
            }
          }
        end

        it 'returns validation errors' do
          result = exec_mutation(mutation_string, vars: variables)
          expect(result['data']).to be_nil
          expect(result['errors']).not_to be_empty
          expect(result['errors'].first['message']).to include("Expected value to not be null")
        end

        it 'does not create a character' do
          expect {
            exec_mutation(mutation_string, vars: variables)
          }.not_to change(Character, :count)
        end
      end

      context 'missing description' do
        let(:variables) do
          {
            input: {
              name: "Nameless"
            }
          }
        end

        it 'returns validation errors' do
          result = exec_mutation(mutation_string, vars: variables)
          expect(result['data']).to be_nil
          expect(result['errors']).not_to be_empty
          expect(result['errors'].first['message']).to include("Expected value to not be null")
        end
      end

      context 'missing default_model' do
        let(:variables) do
          {
            input: {
              name: "Test Character",
              description: "Test description",
              defaultModel: ""
            }
          }
        end

        it 'returns validation errors' do
          result = exec_mutation(mutation_string, vars: variables)
          expect(result['data']['createCharacter']['character']).to be_nil
          expect(result['data']['createCharacter']['errors']).to include("Default model can't be blank")
        end
      end

      context 'empty name string' do
        let(:variables) do
          {
            input: {
              name: "",
              description: "Test description"
            }
          }
        end

        it 'returns validation errors' do
          result = exec_mutation(mutation_string, vars: variables)
          expect(result['data']['createCharacter']['character']).to be_nil
          expect(result['data']['createCharacter']['errors']).to include("Name can't be blank")
        end
      end

      context 'empty description string' do
        let(:variables) do
          {
            input: {
              name: "Test Character",
              description: ""
            }
          }
        end

        it 'returns validation errors' do
          result = exec_mutation(mutation_string, vars: variables)
          expect(result['data']['createCharacter']['character']).to be_nil
          expect(result['data']['createCharacter']['errors']).to include("Description can't be blank")
        end
      end
    end

    context 'without authentication' do
      let(:context) { {} }
      let(:variables) do
        {
          input: {
            name: "Unauthorized Character",
            description: "Should not be created"
          }
        }
      end

      it 'returns an authentication error' do
        result = exec_mutation(mutation_string, vars: variables)
        expect(result['data']['createCharacter']['character']).to be_nil
        expect(result['data']['createCharacter']['errors']).to include("Authentication required")
      end

      it 'does not create a character' do
        expect {
          exec_mutation(mutation_string, vars: variables)
        }.not_to change(Character, :count)
      end
    end

    context 'edge cases' do
      context 'with empty arrays' do
        let(:variables) do
          {
            input: {
              name: "Edge Case Character",
              description: "Testing edge cases",
              alternateNames: [],
              tags: []
            }
          }
        end

        it 'creates a character with empty arrays' do
          result = exec_mutation(mutation_string, vars: variables)
          expect(result['errors']).to be_nil

          character_data = result['data']['createCharacter']['character']
          expect(character_data['alternateNames']).to eq([])
          expect(character_data['tags']).to eq([])
        end
      end

      context 'with maximum field lengths' do
        let(:long_name) { "A" * 255 }
        let(:long_description) { "B" * 5000 }

        let(:variables) do
          {
            input: {
              name: long_name,
              description: long_description,
              alternateNames: Array.new(10) { |i| "AltName#{i}" },
              tags: Array.new(50) { |i| "tag#{i}" }
            }
          }
        end

        it 'handles long field values appropriately' do
          result = exec_mutation(mutation_string, vars: variables)

          # This test assumes the database/model accepts these lengths
          # If there are length validations, this would test those limits
          if result['data']['createCharacter']['character']
            character_data = result['data']['createCharacter']['character']
            expect(character_data['name']).to eq(long_name)
            expect(character_data['description']).to eq(long_description)
          else
            # If validations prevent creation, check for appropriate error messages
            expect(result['data']['createCharacter']['errors']).not_to be_empty
          end
        end
      end
    end

    context 'return value structure' do
      let(:variables) do
        {
          input: {
            name: "Structure Test",
            description: "Testing return structure"
          }
        }
      end

      it 'returns the expected structure on success' do
        result = exec_mutation(mutation_string, vars: variables)

        expect(result).to have_key('data')
        expect(result['data']).to have_key('createCharacter')

        create_character_result = result['data']['createCharacter']
        expect(create_character_result).to have_key('character')
        expect(create_character_result).to have_key('errors')

        expect(create_character_result['errors']).to be_an(Array)
        expect(create_character_result['character']).to be_a(Hash)

        character = create_character_result['character']
        expect(character).to have_key('id')
        expect(character).to have_key('name')
        expect(character).to have_key('description')
        expect(character).to have_key('alternateNames')
        expect(character).to have_key('tags')
        expect(character).to have_key('public')
        expect(character).to have_key('defaultModel')
        expect(character).to have_key('createdAt')
        expect(character).to have_key('updatedAt')
        expect(character).to have_key('user')
      end
    end
  end
end
