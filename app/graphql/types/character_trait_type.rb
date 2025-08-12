module Types
  class CharacterTraitType < Types::BaseObject
    description "A trait represents a characteristic or attribute of a character"

    field :id, ID, null: false, description: "ID of the trait"
    field :trait_type, String, null: false, description: "Type of the trait"
    field :value, String, null: false, description: "Value of the trait"
  end
end
