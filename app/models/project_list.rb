# === Attributes
#
# * *listable_id* (+integer+)
# * *listable_type* (+string+)
# * *created_at* (+datetime+)
# * *updated_at* (+datetime+)
# * *title* (+string+)
# * *show_active* (+boolean+)
# * *show_funded* (+boolean+)
# * *show_nonfunded* (+boolean+)
# * *permanent* (+boolean+)
class ProjectList < List
  has_many :project_listings, order: "position", foreign_key: :list_id

  # Options:
  # limit - optional limit to number of projects you want
  # as_owner - whether or not the list is being viewed by its owner.
  #     If true, then all projects are displayed, even unconfirmed, inactive, and cancelled ones
  def sorted_projects(options)
    limit = options[:limit] || Project.count
    projects = []
    if listable == User.find_by_id(1)
      projects << Project.find_by_state(:active) if show_active
      projects << Project.find_by_state(:funded) if show_funded
      projects << Project.find_by_state(:nonfunded) if show_nonfunded
    else
      projects << listable.projects.where(state: :active) if show_active
      projects << listable.projects.where(state: :funded) if show_funded
      projects << listable.projects.where(state: :nonfunded) if show_nonfunded
      if options[:as_owner]
        projects << listable.projects.where(state: :unconfirmed)
        projects << listable.projects.where(state: :inactive)
        projects << listable.projects.where(state: :cancelled)
      end
    end
    projects.flatten!
    projects.compact! # remove nil elements

    projects.sort_by(&:position).slice!(0,limit)
  end

  alias listings project_listings
end
