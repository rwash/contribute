class AddBlockedToUser < ActiveRecord::Migration
  def change
    add_column :users, :blocked, :boolean, default: false
    add_index :users, :blocked
  end
end
