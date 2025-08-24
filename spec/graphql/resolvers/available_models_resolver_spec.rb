require 'rails_helper'

RSpec.describe Resolvers::AvailableModelsResolver, type: :request do
  def exec_query(query_string, vars: {})
    HivemindSchema.execute(query_string, variables: vars, context: {})
  end

  describe 'availableModels query' do
    let(:query_string) do
      <<~GQL
        query {
          availableModels
        }
      GQL
    end

    it 'returns available models' do
      result = exec_query(query_string)

      expect(result['errors']).to be_nil
      expect(result['data']['availableModels']).to be_an(Array)
      expect(result['data']['availableModels']).to include('Llama 3.2')
    end

    it 'returns an array of strings' do
      result = exec_query(query_string)

      models = result['data']['availableModels']
      expect(models).to be_an(Array)
      models.each do |model|
        expect(model).to be_a(String)
      end
    end

    it 'does not require authentication' do
      # Test that the query works without current_user in context
      result = exec_query(query_string)

      expect(result['errors']).to be_nil
      expect(result['data']['availableModels']).not_to be_empty
    end

    it 'returns consistent results' do
      result1 = exec_query(query_string)
      result2 = exec_query(query_string)

      expect(result1['data']['availableModels']).to eq(result2['data']['availableModels'])
    end

    context 'response structure' do
      it 'returns the expected structure' do
        result = exec_query(query_string)

        expect(result).to have_key('data')
        expect(result['data']).to have_key('availableModels')
        expect(result['data']['availableModels']).to be_an(Array)
      end
    end
  end
end
