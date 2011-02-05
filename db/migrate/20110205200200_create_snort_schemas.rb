class CreateSnortSchemas < ActiveRecord::Migration
  def self.up  
    create_table(:snort_schema) do |t|
      t.integer :vseq
      t.datetime :ctime
      t.string :version
    end
    
  end

  def self.down
    drop_table :snort_schema
  end
end
