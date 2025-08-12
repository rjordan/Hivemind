class CreateConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :conversations, id: :uuid do |t|
      t.string :title, null: false
      t.references :persona, type: :uuid, null: false, foreign_key: true
      t.string :tags, array: true, default: [], limit: 50
      t.boolean :assistant, default: true # Indicates if the conversation is with an assistant
      t.text :scenario, null: false
      t.text :initial_message, null: true
      t.string :conversation_model, null: false

      t.timestamps
    end
    add_index :conversations, :tags, using: 'gin'

    create_table :character_conversations, id: :uuid do |t|
      t.references :character, type: :uuid, null: false, foreign_key: true
      t.references :conversation, type: :uuid, null: false, foreign_key: true
      t.boolean :present, default: true
    end
    add_index :character_conversations, [:conversation_id, :character_id], unique: true, name: 'index_characters_conversations_on_conversation_and_user'

    create_table :conversation_facts, id: :uuid do |t|
      t.references :conversation, type: :uuid, null: false, foreign_key: true
      t.string :fact, null: false
      t.timestamps
    end
  end
end
