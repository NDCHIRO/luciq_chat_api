class CreateChats < ActiveRecord::Migration[8.0]
  def change
    create_table :chats do |t|
      t.references :application, null: false, foreign_key: true
      t.integer :number, null: false
      t.integer :messages_count, null: false, default: 0

      t.timestamps
    end

    # Ensure chat numbers are unique within each application
    add_index :chats, [:application_id, :number], unique: true
  end
end
