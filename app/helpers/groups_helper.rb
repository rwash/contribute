module GroupsHelper
  def group_admin?(g)
    return false if current_user.nil?
    g.admin_user == current_user
  end
end
