class CreateFavorites < ActiveRecord::Migration
  def self.up  
    create_table(:favorite) do |t|
      t.integer :sid
      t.integer :cid
      t.integer :user_id
    end
    
    add_index :favorite, :sid
    add_index :favorite, :cid
    
  end

  def self.down
    drop_table :favorite
  end
end
