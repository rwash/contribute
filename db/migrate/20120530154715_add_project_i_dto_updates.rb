class AddProjectIDtoUpdates < ActiveRecord::Migration
  def up
    add_column :updates, :project_id, :integer
  end

  def down
  end
end
