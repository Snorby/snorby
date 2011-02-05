class CreateIcmps < ActiveRecord::Migration
  def self.up  
    create_table(:icmp) do |t|
      t.integer :sid
      t.integer :cid
      t.integer :icmp_type
      t.integer :icmp_code
      t.integer :icmp_csum
      t.integer :icmp_id
      t.integer :icmp_seq
    end
    
    add_index :icmp, :sid
    add_index :icmp, :cid    
    
  end

  def self.down
    drop_table :icmp
  end
end
