class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :logged_in?, :yt_client, :get_projects_in_order, :confirmation_approver?

  # Ensure authorization happens on every action in the application.
  # This will raise an exception if authorization is not performed in an action.
  # See https://github.com/ryanb/cancan#4-lock-it-down
  check_authorization unless: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    if exception.action == :contribute
      redirect_to exception.subject, alert: exception.message
    elsif exception.action == :edit_contribution
      redirect_to exception.subject, alert: exception.message
    elsif exception.action == :create_update_for
      redirect_to exception.subject, alert: exception.message
    else
      redirect_to root_url, alert: exception.message
    end
  end

  def logged_in?
    !current_user.nil?
  end

  def yt_client
    @yt_client ||= YouTubeIt::Client.new(username: YT_USERNAME , password: YT_PASSWORD , dev_key: YT_DEV_KEY)
  end

  # list - list to get projects for
  # limit - optional limit to number of projects you want
  # TODO move this somewhere else
  def get_projects_in_order(list,limit = Project.count)
    @projects = []
    unless list.listable_type == "User" and list.listable.id == 1
      @projects << list.listable.projects.where(state: :active) if list.show_active
      @projects << list.listable.projects.where(state: :funded) if list.show_funded
      @projects << list.listable.projects.where(state: :nonfunded) if list.show_nonfunded
      if list.listable_type == "User" and list.permanent? and !current_user.nil? and current_user.id == list.listable.id
        @projects << list.listable.projects.where(state: :unconfirmed)
        @projects << list.listable.projects.where(state: :inactive)
        @projects << list.listable.projects.where(state: :cancelled)
      end
    else
      @projects << Project.find_by_state(:active) if list.show_active
      @projects << Project.find_by_state(:funded) if list.show_funded
      @projects << Project.find_by_state(:nonfunded) if list.show_nonfunded
    end
    @projects.flatten!
    @projects.compact! # remove nil elements

    case list.kind
    when "manual"
      @projects = []
      for item in list.items.order("position DESC").limit(limit)
        @projects << item.itemable
      end
      @projects
    when "created-at-descending"
      @projects.sort {|a,b| b.created_at <=> a.created_at }.slice!(0,limit)
    when "created-at-ascending"
      @projects.sort {|a,b| a.created_at <=> b.created_at }.slice!(0,limit)
    when "end-date-descending"
      @projects.sort {|a,b| b.end_date <=> a.end_date }.slice!(0,limit)
    when "end-date-ascending"
      @projects.sort {|a,b| a.end_date <=> b.end_date }.slice!(0,limit)
    when "funding-goal-descending"
      @projects.sort {|a,b| b.funding_goal <=> a.funding_goal }.slice!(0,limit)
    when "funding-goal-ascending"
      @projects.sort {|a,b| a.funding_goal <=> b.funding_goal }.slice!(0,limit)
    when "amount-left-to-goal-in-dollars-descending"
      @projects.sort {|a,b| b.left_to_goal <=> a.left_to_goal }.slice!(0,limit)
    when "amount-left-to-goal-in-dollars-ascending"
      @projects.sort {|a,b| a.left_to_goal <=> b.left_to_goal }.slice!(0,limit)
    when "amount-left-to-goal-as-percent-descending"
      @projects.sort {|a,b| a.contributions_percentage <=> b.contributions_percentage }.slice!(0,limit)
    when "amount-left-to-goal-as-percent-ascending"
      @projects.sort {|a,b| b.contributions_percentage <=> a.contributions_percentage }.slice!(0,limit)
    when "amount-donated-in-dollars-descending"
      @projects.sort {|a,b| b.contributions_total <=> a.contributions_total }.slice!(0,limit)
    when "amount-donated-in-dollars-ascending"
      @projects.sort {|a,b| a.contributions_total <=> b.contributions_total }.slice!(0,limit)
    when "amount-donated-as-percent-of-goal-descending"
      @projects.sort {|a,b| b.contributions_percentage <=> a.contributions_percentage }.slice!(0,limit)
    when "amount-donated-as-percent-of-goal-ascending"
      @projects.sort {|a,b| a.contributions_percentage <=> b.contributions_percentage }.slice!(0,limit)
    when "random-descending"
      @projects.shuffle.slice!(0,limit)
    when "random-ascending"
      @projects.shuffle.slice!(0,limit)
    else #default
      @projects.sort {|a,b| b.created_at <=> a.created_at }.slice!(0,limit)
    end
  end
end
