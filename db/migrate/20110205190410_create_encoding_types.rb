class CreateEncodingTypes < ActiveRecord::Migration
  def self.up
    create_table(:encoding_type) do |t|
      t.integer :encoding_type
      t.text :encoding_text
    end
  end

  def self.down
    drop_table :encoding_type
  end
end
