# === Attributes
#
# * *name* (+string+)
# * *description* (+string+)
# * *open* (+boolean+)
# * *admin_user_id* (+integer+)
# * *picture_file_name* (+string+)
# * *picture_content_type* (+string+)
# * *picture_file_size* (+integer+)
# * *picture_updated_at* (+datetime+)
# * *created_at* (+datetime+)
# * *updated_at* (+datetime+)
# * *long_description* (+string+)
class Group < ActiveRecord::Base
  has_and_belongs_to_many :projects
  has_many :approvals

  belongs_to :admin_user, class_name: "User"

  validates :name,
            presence: true,
            uniqueness: { case_sensitive: false }

  validates :admin_user, presence: true

  mount_uploader :picture, PictureUploader, mount_on: :picture_file_name

  after_save :approve_all

  def approve_all
    if self.open
      for approval in self.approvals.where(status: :pending)
        group = approval.group
        project = approval.project

        approval.status = :approved
        approval.save

        group.projects << project unless group.projects.include?(project)
        project.update_project_video
      end
    end
  end
end
