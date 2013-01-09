class CreateApprovals < ActiveRecord::Migration
  def up
    create_table :approvals do |t|
      t.integer :group_id
      t.integer :project_id
      t.boolean :approved

      t.timestamps
    end
  end

  def down
    drop_table :approvals
  end
end
