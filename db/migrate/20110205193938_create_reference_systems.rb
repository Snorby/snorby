class CreateReferenceSystems < ActiveRecord::Migration
  def self.up  
    create_table(:reference_system) do |t|
      t.integer :ref_system_id
      t.string :ref_system_name
    end
    
    add_index :reference_system, :ref_system_id
    
  end

  def self.down
    drop_table :reference_system
  end
end
