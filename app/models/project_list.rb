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

  # sorted_projects returns the lists' projects, sorted by the
  # position attribute on the Listing object.
  #
  # Options:
  # limit - optional limit to number of projects you want
  # as_owner - whether or not the list is being viewed by its owner.
  #     If true, then all projects are displayed, even unconfirmed, inactive, and cancelled ones
  def sorted_projects(options)
    limit = options[:limit] || Project.count

    projects = listings.map(&:item)
    unless options[:as_owner]
      projects.select! { |p| p.state.active? or p.state.funded? or p.state.nonfunded? }
    end

    projects.slice(0,limit)
  end

  alias listings project_listings
end
