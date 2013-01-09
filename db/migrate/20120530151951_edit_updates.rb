class EditUpdates < ActiveRecord::Migration
  def up
    remove_column :updates, :userid
    add_column :updates, :user_id, :integer
  end

  def down
  end
end
