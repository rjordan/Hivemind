class Types::ConversationType < Types::BaseObject
  field :id, ID, null: false
  field :title, String, null: false
  field :tags, [String], null: false
  field :assistant, Boolean, null: false
  field :scenario, String, null: false
  field :initial_message, String, null: true
  field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

  field :persona, Types::PersonaType, null: false, description: "Persona associated with the conversation"
  field :characters, [Types::CharacterType], null: false, description: "Characters associated with the conversation"

  field :facts, [String], null: false, description: "Facts associated with the conversation"
end
