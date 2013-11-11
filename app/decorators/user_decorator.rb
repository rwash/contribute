# Adds functionality to User objects through the use of the decorator pattern
#
# Functionality enabled by the 'draper' gem (https://github.com/drapergem/draper)
#
# Decorators are part of the View division of MVC, and contain all of the logic that isn't
# appropriate for the Model or Controller to manage.
#
# Decorator objects should contain all complex logic necessary for rendering views.
# It is also a good place for reusable single lines of code, such as buttons
# that are used in multiple places and have a consistent appearance throughout the site.
class UserDecorator < Draper::Decorator
  decorates :user
  delegate_all

  # Allows the use of helpers without a proxy (see Draper documentation)
  include Draper::LazyHelpers

  def picture_url version
    model.picture? ? model.picture.url(version) : 'defaultProfilePic.jpg'
  end

  def show_page_image_tag
    image_tag picture_url :show
  end

  def picture_tag
    image_tag picture_url, :class => "userImage", :width=>"50"
  end
end
