# frozen_string_literal: true

module Types
  class CreateCharacterInput < Types::BaseInputObject
    description "Input for creating a character"

    argument :name, String, required: true, description: "Name of the character"
    argument :description, String, required: true, description: "Description of the character"
    argument :alternate_names, [ String ], required: false, description: "Alternate names for the character"
    argument :tags, [ String ], required: false, description: "Tags associated with the character"
    argument :public, Boolean, required: false, description: "Whether the character is public"
    argument :default_model, String, required: false, description: "Default AI model for the character"
  end
end
