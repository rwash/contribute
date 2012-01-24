class AddCategoryIdToProjects < ActiveRecord::Migration
  def change
		add_column :projects, :categoryId, :integer
  end
end
