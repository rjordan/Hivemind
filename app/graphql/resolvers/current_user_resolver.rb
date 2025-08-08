module Resolvers
  class CurrentUserResolver < BaseResolver
    description "Fetch the currently authenticated user"

    type Types::UserType, null: false

    def resolve
      raise GraphQL::ExecutionError, "Authentication required" unless context[:current_user]

      context[:current_user]
    end
  end
end
