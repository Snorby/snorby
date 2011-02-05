class CreateUdps < ActiveRecord::Migration
  def self.up  
    create_table(:udp) do |t|
      t.integer :sid
      t.integer :cid
      t.integer :udp_sport
      t.integer :udp_dsport
      t.integer :udp_len
      t.integer :udp_csum
    end
    
    add_index :udp, :sid
    add_index :udp, :cid
    
  end

  def self.down
    drop_table :udp
  end
end
