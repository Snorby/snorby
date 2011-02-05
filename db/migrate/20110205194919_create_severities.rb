class CreateSeverities < ActiveRecord::Migration
  def self.up  
    create_table(:severity) do |t|
      t.integer :sig_id
      t.integer :events_count
      t.string :name
      t.string :text_color, :default => '#fff'
      t.string :bg_color, :default => '#ddd'
      
    end
    
    add_index :severity, :sig_id
    add_index :severity, :events_count
    add_index :severity, :text_color
    add_index :severity, :bg_color
    
  end

  def self.down
    drop_table :severity
  end
end
