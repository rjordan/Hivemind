module Types
  class PersonaType < Types::BaseObject
    description "A persona represents a user's identity in a conversation"

    field :id, ID, null: false, description: "ID of the persona"
    field :name, String, null: false, description: "Name of the persona"
    field :description, String, null: true, description: "Description of the persona"
    field :default, Boolean, null: false, description: "Whether this is the default persona"
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false, description: "Timestamp when the persona was created"
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false, description: "Timestamp when the persona was last updated"

    field :user, UserType, null: false, description: "User associated with the persona"
    # Probably don't need a connection here?
    field :conversations, [ ConversationType ], null: false, description: "Conversations associated with the persona"
  end
end
