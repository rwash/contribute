class AddUrlNameToProjects < ActiveRecord::Migration
  def change
		add_column :projects, :url_name, :string
  end
end
