class CreateSignatures < ActiveRecord::Migration
  def self.up  
    create_table(:signature) do |t|
      t.integer :sig_id
      t.integer :sig_class_id
      t.text :sig_name
      t.integer :sig_priority
      t.integer :sig_rev
      t.integer :sig_sid
      t.integer :sig_gid
      t.integer :events_count, :default => 0
    end
    
    add_index :signature, :sig_id
    add_index :signature, :sig_class_id
    add_index :signature, :sig_priority
    add_index :signature, :events_count
    
  end

  def self.down
    drop_table :signature
  end
end
