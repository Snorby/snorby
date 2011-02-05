class CreateDetails < ActiveRecord::Migration
  def self.up
    create_table(:detail) do |t|
      t.integer :detail_type
      t.text :detail_text
    end
  end

  def self.down
    drop_table :detail
  end
end
