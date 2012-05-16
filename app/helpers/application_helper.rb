module ApplicationHelper
	def format_date(date)
		date.strftime('%m/%d/%Y')
	end
	
	def logged_in?
	  !current_user.nil?
	end
	
	def comment_owner(comment)
	 logged_in? && current_user.id == comment.userid
	end
end
