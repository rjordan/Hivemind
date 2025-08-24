# frozen_string_literal: true

module Mutations
  class CreateCharacter < BaseMutation
    description "Creates a new character"

    # Arguments
    argument :name, String, required: true, description: "Name of the character"
    argument :description, String, required: true, description: "Description of the character"
    argument :alternate_names, [ String ], required: false, description: "Alternate names for the character"
    argument :tags, [ String ], required: false, description: "Tags associated with the character"
    argument :public, Boolean, required: false, description: "Whether the character is public"
    argument :default_model, String, required: false, description: "Default AI model for the character"

    # Return fields
    field :character, Types::CharacterType, null: true, description: "The created character"
    field :errors, [ String ], null: false, description: "Any errors that occurred"

    def resolve(name:, description:, alternate_names: [], tags: [], public: false, default_model: "llama3.2")
      current_user = context[:current_user]

      unless current_user
        return {
          character: nil,
          errors: [ "Authentication required" ]
        }
      end

      character = current_user.characters.build(
        name: name,
        description: description,
        alternate_names: alternate_names,
        tags: tags,
        public: public,
        default_model: default_model
      )

      if character.save
        {
          character: character,
          errors: []
        }
      else
        {
          character: nil,
          errors: character.errors.full_messages
        }
      end
    end
  end
end
