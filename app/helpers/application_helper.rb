module ApplicationHelper
  def format_date(date)
    date.strftime('%m/%d/%Y')
  end

  def logged_in?
    !current_user.nil?
  end
end
