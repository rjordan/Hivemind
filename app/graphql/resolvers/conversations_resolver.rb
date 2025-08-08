# frozen_string_literal: true

module Resolvers
  class ConversationsResolver < BaseResolver
    description "Fetch all conversations"

    type Types::ConversationType.connection_type, null: false

    def resolve
      raise GraphQL::ExecutionError, "Authentication required" unless context[:current_user]

      context[:current_user].conversations
    end
  end
end
