class AddStatusOptionsToLists < ActiveRecord::Migration
  def change
  	add_column :lists, :show_active, :boolean, :default => true
  	add_column :lists, :show_funded, :boolean, :default => false
  	add_column :lists, :show_nonfunded, :boolean, :default => false
  end
end
