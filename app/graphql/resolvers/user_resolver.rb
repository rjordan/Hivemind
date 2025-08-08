module Resolvers
  class UserResolver < BaseResolver
    description "Fetch a user by ID"

    type Types::UserType, null: true

    argument :id, ID, required: true, description: "ID of the user"

    def resolve(id:)
      raise GraphQL::ExecutionError, "Authentication required" unless context[:current_user]

      User.find_by(id: id)
    end
  end
end
