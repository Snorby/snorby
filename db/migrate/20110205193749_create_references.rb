class CreateReferences < ActiveRecord::Migration
  def self.up  
    create_table(:reference) do |t|
      t.integer :ref_id
      t.integer :ref_system_id
      t.text :tef_tag
    end
    
    add_index :reference, :ref_id
    
  end

  def self.down
    drop_table :reference
  end
end
