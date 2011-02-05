class CreateCaches < ActiveRecord::Migration
  def self.up
    create_table(:cache) do |t|
      t.integer :sid
      t.integer :cid
      t.datetime :ran_at
      t.integer :event_count, :default => 0
      t.integer :tcp_count, :default => 0
      t.integer :udp_count, :default => 0
      t.integer :icmp_count, :default => 0
      t.text :severity_metrics
      t.text :signature_metrics
      t.text :src_ips
      t.text :dst_ips
      
      t.timestamps
    end
    
    add_index :cache, :sid
    add_index :cache, :cid
  end

  def self.down
    drop_table :cache
  end
end
