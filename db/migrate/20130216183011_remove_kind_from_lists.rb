class RemoveKindFromLists < ActiveRecord::Migration
  def up
    remove_column :lists, :kind
  end

  def down
    add_column :lists, :kind, :string, default: 'default'
  end
end
