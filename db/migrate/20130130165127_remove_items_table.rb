class RemoveItemsTable < ActiveRecord::Migration
  def up
    drop_table :items
  end

  def down
    create_table :items do |t|
      t.integer :itemable_id, :null => false
      t.string :itemable_type, :null => false, :limit => 20 #could be even less
      t.integer :list_id
      t.integer :position, :default => 0

      t.timestamps
    end

    add_index :items, [:itemable_id, :itemable_type]
  end
end
