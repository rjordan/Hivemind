# frozen_string_literal: true

require_relative '../lib/db'
require_relative '../lib/models'

module HivemindMCP
  class GetCharacterTool < FastMcp::Tool
    description "Fetch a character by ID (uses DB when configured, otherwise GraphQL)"

    arguments do
      required(:id).filled(:string).description("Character ID")
    end

    def call(id:)
      record = Character.find_by(id: id_extracted(id))
      return {} unless record
      return serialize_character(record)
    end

    private

    def id_extracted(id)
      # handle both raw UUID and Rails Global ID formats
      if id.to_s.include?('gid://')
        id.split('/').last
      else
        id
      end
    end

    def serialize_character(record)
      {
        'id' => "gid://hivemind/Character/#{record.id}",
        'name' => record.name,
        'alternate_names' => Array(record.alternate_names),
        'tags' => Array(record.tags),
        'public' => !!record.public
      }
    end
  end
end
