class AddVideoToProject < ActiveRecord::Migration
  def change
    add_column :projects, :video_id, :integer
  end
end
