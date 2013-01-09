class CreateGroupsProjectsTable < ActiveRecord::Migration
  def up
    create_table :groups_projects, :id => false do |t|
      t.references :group, :null => false
      t.references :project, :null => false
    end
    add_index(:groups_projects, [:group_id, :project_id], :unique => true)
  end

  def down
    drop_table :groups_projects
  end
end
