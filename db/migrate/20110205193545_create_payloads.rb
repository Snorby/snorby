class CreatePayloads < ActiveRecord::Migration
  def self.up  
    create_table(:payload) do |t|
      t.integer :sid
      t.integer :cid
      t.text :data_payload
    end
    
    add_index :payload, :sid
    add_index :payload, :cid  
    
  end

  def self.down
    drop_table :payload
  end
end
