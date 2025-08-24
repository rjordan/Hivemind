module Types
  class CharacterType < Types::BaseObject
    description "A character represents a fictional persona in a conversation"

    field :id, ID, null: false, description: "ID of the character"
    field :name, String, null: false, description: "Name of the character"
    field :alternate_names, [ String ], null: false, description: "Alternate names of the character"
    field :tags, [ String ], null: false, description: "Tags associated with the character"
    field :public, Boolean, null: false, description: "Visibility status of the character"
    field :description, String, null: false, description: "Description of the character"
    field :default_model, String, null: false, description: "Default AI model for the character"
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false, description: "Timestamp when the character was created"
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false, description: "Timestamp when the character was last updated"

    field :facts, [ Types::CharacterFactType ], null: false, description: "Facts associated with the character"
    field :conversations, [ Types::ConversationType ], null: false, description: "Conversation associated with the character"
    field :user, Types::UserType, null: false, description: "User associated with the character"
  end
end
