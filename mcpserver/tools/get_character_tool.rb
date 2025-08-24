# frozen_string_literal: true

require 'fast_mcp'
require 'json'

require_relative '../lib/request_context'

GRAPHQL_URL = ENV['HIVEMIND_API_URL']

module HivemindMCP
  class GetCharacterTool < ::FastMcp::Tool
    description "Fetch a character by ID via GraphQL API"

    arguments do
      required(:id).filled(:string).description("Character ID")
    end

    def call(id:)
      result = fetch_character_via_graphql(id)
      return result.to_json
    end

    private

    def build_character_query(id)
      <<~GRAPHQL
        query GetCharacter($id: ID!) {
          character(id: $id) {
            id
            name
            alternateNames
            tags
            public
            facts {
              fact
            }
          }
        }
      GRAPHQL
    end

    def fetch_character_via_graphql(id)
      graphql_url = GRAPHQL_URL || ENV['HIVEMIND_API_URL'] || ENV['GRAPHQL_API_URL'] || 'http://localhost:3000/graphql'
      query = build_character_query(id_extracted(id))

      begin
        conn = HivemindMCP::RequestContext.authenticated_connection(graphql_url)
        response = conn.post('') do |req|
          req.body = { query: query }
        end

        if response.success?
          data = response.body.dig('data', 'character')
          if data
            {
              id: data['id'],
              name: data['name'],
              alternateNames: Array(data['alternateNames']),
              tags: Array(data['tags']),
              public: data['public'],
              facts: Array(data['facts']).map { |f| f['fact'] },
              source: 'graphql'
            }
          else
            errors = response.body['errors']&.map { |e| e['message'] }&.join(', ')
            { error: "Character not found#{errors ? " (#{errors})" : ""}" }
          end
        else
          { error: "GraphQL request failed: #{response.status} #{response.reason_phrase}" }
        end
      rescue StandardError => e
        { error: "Error fetching character via GraphQL: #{e.message}" }
      end
    end


    def id_extracted(id)
      # handle both raw UUID and Rails Global ID formats
      if id.to_s.include?('gid://')
        id.split('/').last
      else
        id
      end
    end
  end
end
