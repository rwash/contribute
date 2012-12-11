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
class ProjectDecorator < Draper::Base
  decorates :project

  @@color_classes = {'unconfirmed' => 'warning', 'inactive' => 'warning',
    'active' => 'success', 'funded' => 'success',
    'nonfunded' => 'inverse', 'canceled' => 'inverse'}

  # Allows the use of helpers without a proxy (see Draper documentation)
  include Draper::LazyHelpers

  # Generates a colored span describing the state of the project
  def colored_state_description
    content_tag :span, "Project State: #{state_name}", class: "label label-#{color_class}"
  end

  # Generates a button linking to the edit page for the project
  def edit_button
    button_to "Edit Project", edit_project_path(@project), :method => 'get', :class => 'btn btn-info btn-large'
  end

  # Generates a button linking to the delete action for the project
  def delete_button
    button_to "Delete Project", @project, :method => :delete, :confirm => "Are you sure you want to delete this project?", :class => 'btn btn-danger btn-large'
  end

  # Generates a button linking to the activate action for the project
  def activate_button
    button_to "Activate Project", activate_project_path(@project), :method => :put, :confirm => "Are you sure you want to activate this project? You will not be able to edit the project once it is active.", :class => 'btn btn-success btn-large'
  end

  # Generates a button linking to the cancel action for the project
  def cancel_button
    button_to "Cancel Project", @project, :method => :delete, :confirm => "Are you sure you want to cancel this project? All contributions to it will also be canceled.", :class => 'btn-danger btn-large'
  end

  private

  # Returns a pretty-printed version of the project state name.
  def state_name
    result = model.state.titlecase
    if model.state == 'funded'
      result = 'Funded!'
    elsif model.state == 'nonfunded'
      result = 'Non-funded'
    end
    result
  end

  # Returns a class label for a project state
  # that will be used by the CSS to apply color to the project state span
  def color_class
    @@color_classes[model.state] || 'important'
  end
end
