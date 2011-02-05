class CreateTcps < ActiveRecord::Migration
  def self.up  
    create_table(:tcp) do |t|
      t.integer :sid
      t.integer :cid
      t.integer :tcp_sport
      t.integer :tcp_dsport
      t.integer :tcp_seq
      t.integer :tcp_ack
      t.integer :tcp_off
      t.integer :tcp_res
      t.integer :tcp_flags
      t.integer :tcp_win
      t.integer :tcp_csum
      t.integer :tcp_urp
    end
    
    add_index :tcp, :sid
    add_index :tcp, :cid
    add_index :tcp, :tcp_sport
    add_index :tcp, :tcp_dsport
    
  end

  def self.down
    drop_table :tcp
  end
end
