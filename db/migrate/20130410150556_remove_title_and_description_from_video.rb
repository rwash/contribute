class RemoveTitleAndDescriptionFromVideo < ActiveRecord::Migration
  def up
    remove_column :videos, :title
    remove_column :videos, :description
  end

  def down
    add_column :videos, :description, :string
    add_column :videos, :title, :string
  end
end
