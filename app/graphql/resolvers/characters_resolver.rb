# frozen_string_literal: true

module Resolvers
  class CharactersResolver < BaseResolver
    description "Fetch characters"

    type Types::CharacterType.connection_type, null: false

    argument :include_public, Boolean, required: false

    def resolve(include_public: false)
      raise GraphQL::ExecutionError, "Authentication required" unless context[:current_user]

      result = Character.where(user: context[:current_user])
      if include_public
        result = result.or(Character.where(public: include_public))
      end
      result = result.order(:name)
      result.includes(:facts, :user, :conversations)
    end
  end
end
