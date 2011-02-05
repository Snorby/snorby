class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table(:event) do |t|
      t.integer :sid
      t.integer :cid
      t.integer :sig_id
      t.integer :classification_id, :null => true
      
      t.integer :users_count, :default => 0
      t.integer :notes_count, :default => 0
      t.integer :user_id
      
      t.timestamps
    end
    
    add_index :event, :sid
    add_index :event, :cid
    add_index :event, :sig_id
    add_index :event, :classification_id
    add_index :event, :user_id
    
  end

  def self.down
    drop_table :event
  end
end