module Types
  class CharacterFactType < Types::BaseObject
    description "A trait represents a characteristic or attribute of a character"

    field :id, ID, null: false, description: "ID of the fact"
    field :fact, String, null: false, description: "Value of the fact"
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false, description: "Timestamp when the fact was created"
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false, description: "Timestamp when the fact was last updated"
  end
end
