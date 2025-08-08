module Types
  class CharacterType < Types::BaseObject
    description "A character represents a fictional persona in a conversation"

    field :id, ID, null: false, description: "ID of the character"
    field :name, String, null: false, description: "Name of the character"
    field :alternate_names, [String], null: false, description: "Alternate names of the character"
    field :tags, [String], null: false, description: "Tags associated with the character"
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false, description: "Timestamp when the character was created"
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false, description: "Timestamp when the character was last updated"

    field :conversations, [Types::ConversationType], null: false, description: "Conversation associated with the character"
    field :user, Types::UserType, null: false, description: "User associated with the character"
    field :facts, [String], null: false, description: "Facts associated with the character"
  end
end
