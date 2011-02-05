class CreateIps < ActiveRecord::Migration
  def self.up  
    create_table(:ip) do |t|
      t.integer :sid
      t.integer :cid
      t.integer :ip_src, :default => 0
      t.integer :ip_dst, :default => 0
      t.integer :ip_ver, :default => 0
      t.integer :ip_hlen, :default => 0
      t.integer :ip_tos, :default => 0
      t.integer :ip_len, :default => 0
      t.integer :ip_id, :default => 0
      t.integer :ip_flags, :default => 0
      t.integer :ip_off, :default => 0
      t.integer :ip_ttl, :default => 0
      t.integer :ip_proto, :default => 0
      t.integer :ip_csum, :default => 0
    end
    
    add_index :ip, :sid
    add_index :ip, :cid  
    add_index :ip, :ip_src
    add_index :ip, :ip_dst   
    
  end

  def self.down
    drop_table :ip
  end
end
