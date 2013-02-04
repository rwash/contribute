class RenameProjectsIdInListingsTable < ActiveRecord::Migration
  def change
    rename_column :listings, :project_id, :item_id
  end
end
