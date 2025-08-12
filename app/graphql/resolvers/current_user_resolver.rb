module Resolvers
  class CurrentUserResolver < BaseResolver
    description "Fetch the currently authenticated user"

    type Types::UserType, null: true

    def resolve
      context[:current_user]
    end
  end
end
