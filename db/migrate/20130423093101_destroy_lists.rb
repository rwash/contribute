class DestroyLists < ActiveRecord::Migration
  def up
    drop_table :listings
    drop_table :lists
    remove_index :lists, 'listable_id_and_listable_type' rescue nil
  end

  def down
    create_table :listings do |t|
      t.integer  "list_id"
      t.integer  "item_id"
      t.integer  "position"
      t.timestamps
      t.string   "type",       :default => "ProjectListing"
    end

    create_table :lists do |t|
      t.integer  "listable_id",                                             :null => false
      t.string   "listable_type",  :limit => 20,                            :null => false
      t.timestamps
      t.string   "title",                        :default => ""
      t.boolean  "show_active",                  :default => true
      t.boolean  "show_funded",                  :default => false
      t.boolean  "show_nonfunded",               :default => false
      t.boolean  "permanent",                    :default => false
      t.string   "type",                         :default => "ProjectList"
    end

    add_index "lists", ["listable_id", "listable_type"], :name => "index_lists_on_listable_id_and_listable_type"
  end
end
