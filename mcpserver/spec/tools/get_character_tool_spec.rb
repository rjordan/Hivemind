# frozen_string_literal: true

require 'spec_helper'
require_relative '../../tools/get_character_tool'
require_relative '../../lib/request_context'

RSpec.describe HivemindMCP::GetCharacterTool do
  let(:tool) { described_class.new }
  let(:character_id) { 'gid://hivemind/Character/123' }
  let(:graphql_url) { 'http://localhost:3000/graphql' }

  before do
    stub_const('GRAPHQL_URL', graphql_url)
  end

  describe '#call' do
    context 'when GraphQL API returns character data' do
      let(:graphql_response) {
        {
          'data' => {
            'character' => {
              'id' => character_id,
              'name' => 'Trinity',
              'alternateNames' => [ 'Hack Queen' ],
              'tags' => [ 'ops' ],
              'public' => true,
              'facts' => [
                { 'fact' => 'Expert hacker' },
                { 'fact' => 'Works for the resistance' }
              ]
            }
          }
        }
      }

      before do
        stub_request(:post, graphql_url)
          .with(
            body: hash_including('query'),
            headers: { 'Content-Type' => 'application/json' }
          )
          .to_return(
            status: 200,
            body: graphql_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns character data as JSON' do
        result_json = tool.call(id: character_id)
        result = JSON.parse(result_json)

        expect(result).to include(
          'id' => character_id,
          'name' => 'Trinity',
          'alternateNames' => [ 'Hack Queen' ],
          'tags' => [ 'ops' ],
          'public' => true,
          'facts' => [ 'Expert hacker', 'Works for the resistance' ],
          'source' => 'graphql'
        )
      end
    end

    context 'when character is not found' do
      let(:error_response) {
        {
          'data' => { 'character' => nil },
          'errors' => [ { 'message' => 'Character not found' } ]
        }
      }

      before do
        stub_request(:post, graphql_url)
          .to_return(
            status: 200,
            body: error_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns error as JSON' do
        result_json = tool.call(id: character_id)
        result = JSON.parse(result_json)

        expect(result).to include('error' => 'Character not found (Character not found)')
      end
    end

    context 'when GraphQL API returns HTTP error' do
      before do
        stub_request(:post, graphql_url)
          .to_return(status: 500, body: 'Internal Server Error')
      end

      it 'returns error as JSON' do
        result_json = tool.call(id: character_id)
        result = JSON.parse(result_json)

        expect(result).to include('error')
        expect(result['error']).to match(/GraphQL request failed/)
      end
    end

    context 'when network error occurs' do
      before do
        stub_request(:post, graphql_url).to_raise(StandardError.new('Network error'))
      end

      it 'returns error as JSON' do
        result_json = tool.call(id: character_id)
        result = JSON.parse(result_json)

        expect(result).to include('error' => 'Error fetching character via GraphQL: Network error')
      end
    end

    context 'with auth header' do
      let(:auth_token) { 'Bearer test-token-123' }

      before do
        allow(HivemindMCP::RequestContext).to receive(:current_auth_header).and_return(auth_token)

        stub_request(:post, graphql_url)
          .with(headers: { 'Authorization' => auth_token })
          .to_return(
            status: 200,
            body: { 'data' => { 'character' => nil } }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'forwards the auth header to GraphQL API' do
        tool.call(id: character_id)

        expect(WebMock).to have_requested(:post, graphql_url)
          .with(headers: { 'Authorization' => auth_token })
      end
    end
  end

  describe '#id_extracted' do
    it 'extracts ID from Global ID format' do
      gid = 'gid://hivemind/Character/123'
      expect(tool.send(:id_extracted, gid)).to eq('123')
    end

    it 'returns raw ID when not in Global ID format' do
      id = '456'
      expect(tool.send(:id_extracted, id)).to eq('456')
    end
  end
end
