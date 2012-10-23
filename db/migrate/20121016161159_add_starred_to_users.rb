class AddStarredToUsers < ActiveRecord::Migration
  def change
    add_column :users, :starred, :boolean
  end
end
