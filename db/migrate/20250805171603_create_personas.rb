class CreatePersonas < ActiveRecord::Migration[8.0]
  def change
    create_table :personas, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.boolean :default
      t.timestamps
    end
  end
end
