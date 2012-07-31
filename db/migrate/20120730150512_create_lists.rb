class CreateQueues < ActiveRecord::Migration
  def up
  	create_table :lists do |t|
  		t.string :type, :default => "default"
  		t.integer :listable_id, :null => false
  		t.string :listable_type, :null => false, :limit => 20 #could be even less
  
  		t.timestamps
    end
    
    add_index :lists, [:listable_id, :listable_type]
    
    create_table :project_items do |t|
    	t.integer :project_id
    	t.integer :list_id
  		t.integer :position
    	
    	t.timestamps
    end
    
    create_table :group_items do |t|
    	t.integer :group_id
    	t.integer :list_id
  		t.integer :position
    	
    	t.timestamps
    end
    
  end

  def down
  	drop_table :lists
  	drop_table :project_items
  	drop_table :group_items
  end
end
