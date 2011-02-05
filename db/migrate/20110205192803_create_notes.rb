class CreateNotes < ActiveRecord::Migration
  def self.up  
    create_table(:note) do |t|
      t.integer :sid
      t.integer :cid
      t.integer :user_id
      t.text :body
    end
    
    add_index :note, :sid
    add_index :note, :cid  
    add_index :note, :user_id
    
  end

  def self.down
    drop_table :note
  end
end
