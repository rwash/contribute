module GroupsHelper
  def group_admin?(group)
    current_user == group.owner
  end
end
