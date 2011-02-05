class CreateSettings < ActiveRecord::Migration
  def self.up  
    create_table(:setting) do |t|
      t.string :name
      t.text :value
      
    end
    
    add_index :setting, :name
    
  end

  def self.down
    drop_table :setting
  end
end
