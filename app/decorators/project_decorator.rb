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

  # Generates a colored span describing the state of the project
  def colored_state_description
    content_tag :span, "Project State: #{model.state.display_string}", class: "label label-#{model.state.color_class}"
  end

  def connect_amazon_button
    button_to "Connect an Amazon account", new_project_amazon_payment_account_path(model), method: :get
  end

  # Generates a button linking to the edit page for the project
  def edit_button
    button_to "Edit Project", edit_project_path(model), method: 'get', class: 'btn btn-info btn-large'
  end

  # Generates a button linking to the delete action for the project
  def delete_button
    button_to "Delete Project", model, method: :delete, confirm: "Are you sure you want to delete this project?", class: 'btn btn-danger btn-large'
  end

  # Generates a button linking to the activate action for the project
  def activate_button
    button_to "Activate Project", activate_project_path(model), method: :put, confirm: "Are you sure you want to activate this project? You will not be able to edit the project once it is active.", class: 'btn btn-success btn-large'
  end

  # Generates a button linking to the cancel action for the project
  def cancel_button
    button_to "Cancel Project", model, method: :delete, confirm: "Are you sure you want to cancel this project? All contributions to it will also be cancelled.", class: 'btn-danger btn-large'
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
      image_tag model.picture.url(:show), :class => "projectImage"
    else
      image_tag "BlockSShow.png", :class => "projectImage"
    end
  end

  def thumbnail_tag
    if picture?
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
end
