require 'rails_helper'

RSpec.describe 'AvailableModels GraphQL Integration', type: :request do
  describe 'POST /graphql' do
    let(:query) do
      <<~GQL
        query {
          availableModels
        }
      GQL
    end

    it 'returns available models through HTTP GraphQL endpoint' do
      post '/graphql', params: { query: query }

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json['errors']).to be_nil
      expect(json['data']['availableModels']).to be_an(Array)
      expect(json['data']['availableModels']).to include('Llama 3.2')
    end

    it 'returns correct content type' do
      post '/graphql', params: { query: query }

      expect(response.content_type).to include('application/json')
    end

    context 'with variables' do
      it 'works with empty variables object' do
        post '/graphql', params: { query: query, variables: {} }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data']['availableModels']).to include('Llama 3.2')
      end
    end

    context 'combined with other queries' do
      let(:combined_query) do
        <<~GQL
          query {
            availableModels
            heartbeat
          }
        GQL
      end

      it 'works alongside other root fields' do
        post '/graphql', params: { query: combined_query }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data']['availableModels']).to include('Llama 3.2')
        expect(json['data']['heartbeat']).to be true
      end
    end
  end
end
