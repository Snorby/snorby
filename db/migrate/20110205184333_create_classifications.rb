class CreateClassifications < ActiveRecord::Migration
  def self.up
    create_table(:classification) do |t|
      t.string :name
      t.text :description
      t.integer :hotkey
      t.boolean :locked, :default => 0
      t.integer :events_count
      
      t.timestamps
    end
    
    add_index :classification, :hotkey
    add_index :classification, :locked
    add_index :classification, :events_count
    
  end

  def self.down
    drop_table :classification
  end
end
