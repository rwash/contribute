module GroupsHelper
  def group_admin?(g)
    return false if current_user.nil?
    g.admin_user_id == current_user.id
  end
end
