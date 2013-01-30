module ApplicationHelper
  def format_date(date)
    date.strftime('%m/%d/%Y')
  end

  def logged_in?
    !current_user.nil?
  end

  def list_owner?(l)
    return false if current_user.nil?
    if l.listable_type == "Group"
      l.listable.admin_user == current_user
    elsif l.listable_type == "User"
      l.listable.id == current_user.id
    else
      false
    end
  end

end
