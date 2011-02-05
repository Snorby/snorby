class CreateOpts < ActiveRecord::Migration
  def self.up  
    create_table(:opt) do |t|
      t.integer :sid
      t.integer :cid
      t.integer :optid
      t.integer :opt_proto
      t.integer :opt_code
      t.integer :opt_len
      t.text :opt_data
    end
    
    add_index :opt, :sid
    add_index :opt, :cid  
    add_index :opt, :optid
    
  end

  def self.down
    drop_table :opt
  end
end
