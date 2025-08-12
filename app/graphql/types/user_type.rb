module Types
  class UserType < Types::BaseObject
    description "A user represents an individual in the system"

    field :id, ID, null: false, description: "ID of the user"
    field :name, String, null: false, description: "Name of the user"
    field :email, String, null: false, description: "Email address of the user"
    field :avatar_url, String, null: true, description: "Avatar URL of the user"
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false, description: "Timestamp when the user was created"
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false, description: "Timestamp when the user was last updated"

    field :personas, [PersonaType], null: false, description: "Personas associated with the user"
    field :conversations, [ConversationType], null: false, description: "Conversations associated with the user"
    field :characters, [CharacterType], null: false, description: "Characters associated with the user"
  end
end
