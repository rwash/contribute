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
  has_many :lists, as:  :listable

  belongs_to :admin_user, class_name: "User"

  validates :name,
            presence: true,
            uniqueness: { case_sensitive: false }

  validates :admin_user, presence: true

  mount_uploader :picture, PictureUploader, mount_on: :picture_file_name

  after_create :add_first_list
  after_save :approve_all

  def approve_all
    if self.open
      for approval in self.approvals.where(approved: nil)
        group = approval.group
        project = approval.project

        approval.approved = true
        approval.save

        group.projects << project unless group.projects.include?(project)
        project.update_project_video
      end
    end
  end

  def add_first_list
    self.lists << List.create(title: "Recent Projects", permanent: true, show_funded: true, show_nonfunded: true, show_active: true)
  end
end
