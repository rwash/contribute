class CreateLists < ActiveRecord::Migration
  def up
  	create_table :lists do |t|
  		t.string :kind, :default => "default"
  		t.integer :listable_id, :null => false
  		t.string :listable_type, :null => false, :limit => 20 #could be even less
  
  		t.timestamps
    end
    
    add_index :lists, [:listable_id, :listable_type]
    
    create_table :items do |t|
    	t.integer :itemable_id, :null => false
  		t.string :itemable_type, :null => false, :limit => 20 #could be even less
    	t.integer :list_id
  		t.integer :position, :default => 0
    	
    	t.timestamps
    end
    
    add_index :items, [:itemable_id, :itemable_type]
    
  end

  def down
  	drop_table :lists
  	drop_table :items
  end
end
