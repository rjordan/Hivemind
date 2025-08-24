# frozen_string_literal: true

module Resolvers
  class AvailableModelsResolver < BaseResolver
    description "Fetch available AI models"

    type [String], null: false

    def resolve
      # For now, return a simple list with just Llama 3.2
      # This can be extended later to read from configuration or external service
      ["Llama 3.2"]
    end
  end
end
