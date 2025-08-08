class CreateCharacters < ActiveRecord::Migration[8.0]
  def change
    create_table :characters, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.string :name
      t.string :alternate_names, array: true, default: []
      t.string :tags, array: true, default: [], limit: 50
      t.timestamps
    end

    add_index :characters, :name
    add_index :characters, :alternate_names, using: 'gin'
    add_index :characters, :tags, using: 'gin'

    create_table :character_traits, id: :uuid do |t|
      t.references :character, type: :uuid, null: false, foreign_key: true
      t.string :trait_type, limit: 50
      t.string :value
      t.timestamps
    end
  end
end
