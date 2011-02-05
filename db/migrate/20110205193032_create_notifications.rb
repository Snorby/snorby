class CreateNotifications < ActiveRecord::Migration
  def self.up  
    create_table(:notification) do |t|
      t.text :description
      t.integer :sig_id
      t.string :ip_src
      t.string :ip_dst
      t.integer :user_id
      t.text :user_ids
      t.text :sensor_ids
    end
    
  end

  def self.down
    drop_table :notification
  end
end
