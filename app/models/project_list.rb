# === Attributes
#
# * *kind* (+string+)
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
  classy_enum_attr :kind, enum: 'ListKind'

  has_many :project_listings, order: "position"

  delegate :sorted_projects, to: :kind
end
