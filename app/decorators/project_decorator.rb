# Adds functionality to Project objects through the use of the decorator pattern
#
# Functionality enabled by the 'draper' gem (https://github.com/drapergem/draper)
#
# Decorators are part of the View division of MVC, and contain all of the logic that isn't
# appropriate for the Model or Controller to manage.
#
# Decorator objects should contain all complex logic necessary for rendering views.
# It is also a good place for reusable single lines of code, such as buttons
# that are used in multiple places and have a consistent appearance throughout the site.
class ProjectDecorator < Draper::Decorator
  decorates :project
  delegate_all

  # Allows the use of helpers without a proxy (see Draper documentation)
  include Draper::LazyHelpers

  def display_contribute_button
    if state.active? && !existing_contribution && current_user != owner
      button_to "Contribute to this project", new_contribution_url(source), :method=>:get, :class => 'success-button'
    end
  end

  def display_edit_contribution_button
    if existing_contribution and can? :edit, existing_contribution
      button_to "Contribute more", edit_contribution_url(existing_contribution),:method => :get
    end
  end

  def existing_contribution
    source.contributions.find_by_user_id(current_user.id) rescue nil
  end

  def remaining_time
    if model.end_date > Date.today
      distance_of_time_in_words(Time.now, model.end_date) + ' left'
    elsif model.end_date == Date.today
      'Project ends today!'
    else
      'Project has ended'
    end
  end

  def media
    if model.video.complete?
      render model.video
    elsif model.picture?
      image_tag model.picture.url(:show)
    else
      image_tag "BlockSShow.png"
    end
  end

  def thumbnail_tag
    if picture.url
      image_tag picture.url(:thumb), :width => '213'
    else
      image_tag "BlockSThumb.png", :width => '213'
    end
  end

  def progress_bar_percentage
    if contributions_percentage >= 1
      contributions_percentage
    else
      1
    end
  end

  def next_step
    if logged_in? and owner == current_user and state.unconfirmed?
      :connect_amazon
    elsif logged_in? and owner == current_user and state.inactive?
      :activate
    end
  end
end
