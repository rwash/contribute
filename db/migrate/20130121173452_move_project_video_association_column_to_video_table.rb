class MoveProjectVideoAssociationColumnToVideoTable < ActiveRecord::Migration
  def up
    add_column :videos, :project_id, :integer
    Project.all.each do |project|
      if project.video_id && project.video
        video = Video.find(project.video_id)
        video.project_id = project.id
      end
    end
    remove_column :projects, :video_id
  end

  def down
    add_column :projects, :video_id, :integer
    Video.all.each do |video|
      if video.project_id && video.project
        project = Project.find(video.project_id)
        project.video_id = video.id
      end
    end
    remove_column :videos, :project_id
  end
end
