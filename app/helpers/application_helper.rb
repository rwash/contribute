module ApplicationHelper
	def format_date(date)
		date.strftime('%m/%d/%Y')
	end
	
  def logged_in?
    !current_user.nil?
  end
  
  def comment_owner(comment)
   logged_in? && current_user.id == comment.user_id
  end
  
  def list_owner?(l)
  	return false if current_user.nil?
		if l.listable_type == "Group"
			l.listable.admin_user_id == current_user.id
		elsif l.listable_type == "User"
			l.listable.id == current_user.id
		else
			false
		end
	end
end
