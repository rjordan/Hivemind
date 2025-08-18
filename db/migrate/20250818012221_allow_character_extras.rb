class AllowCharacterExtras < ActiveRecord::Migration[8.0]
  def change
    add_column :characters, :conversation_id, :uuid, null: true
    add_foreign_key :characters, :conversations
  end
end
