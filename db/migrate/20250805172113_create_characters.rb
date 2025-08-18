class CreateCharacters < ActiveRecord::Migration[8.0]
  def change
    create_table :characters, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.string :name
      t.string :alternate_names, array: true, default: []
      t.string :tags, array: true, default: [], limit: 50
      t.text :description, null: false
      t.string :default_model, null: false, default: "llama3.2"
      t.boolean :public, default: false
      t.timestamps
    end

    add_index :characters, :name
    add_index :characters, :alternate_names, using: 'gin'
    add_index :characters, :tags, using: 'gin'

    create_table :character_facts, id: :uuid do |t|
      t.references :character, type: :uuid, null: false, foreign_key: true
      t.string :fact
      t.timestamps
    end
  end
end
