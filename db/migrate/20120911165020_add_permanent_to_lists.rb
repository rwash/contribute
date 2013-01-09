class AddPermanentToLists < ActiveRecord::Migration
  def change
    add_column :lists, :permanent, :boolean, :default => false
  end
end
