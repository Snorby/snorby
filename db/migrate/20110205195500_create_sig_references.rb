class CreateSigReferences < ActiveRecord::Migration
  def self.up  
    create_table(:sig_reference) do |t|
      t.integer :sig_id
      t.integer :ref_seq
      t.integer :ref_id
    end
    
    add_index :sig_reference, :sig_id
    add_index :sig_reference, :ref_seq
    
  end

  def self.down
    drop_table :sig_reference
  end
end
