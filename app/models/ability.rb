# The Ability class defines what a user can or cannot do throughout the site.
#
# The class includes the CanCan::Ability module, defined in Ryan Bates' CanCan gem.
# The CanCan gem can be found at http://github.com/ryanb/cancan
class Ability
  include CanCan::Ability

  # Sets up user permissions (abilities)
  def initialize(user)
    user ||= User.new

    # Projects
    can :read, Project, public_can_view?: true
    can :create, Project if user.id
    can [:read, :save, :activate, :destroy], Project, user: user
    can :read, Project, confirmation_approver?: true

    # Note: this 'update' refers to the Update and Edit actions of ProjectsController,
    # not the ability to create Update objects associated with a project
    can :update, Project, user: user, can_edit?: true

    can :create, Update do |update|
      update.project.can_update? and
        (update.project.user == user or user.admin?)
    end

    can :destroy, Video do |v|
      v.project.user = user
    end

    # Comments
    can :create, Comment if user.id
    can :destroy, Comment do |comment|
      (user.admin? or comment.user == user) and comment.body != "comment deleted"
    end

    # Contributions
    # Make sure the user isn't a project owner and doesn't have a contribution already
    can :create, Contribution do |contribution|
      user.id and
        (user.admin? or contribution.project.user != user) and
        contribution.project.contributions.find_by_user_id(user.id).nil? and
        contribution.project.end_date >= Time.zone.today
    end
    # If the user is logged in, doesn't own the project,  and has a contribution on this project,
    # they can edit
    can :update, Contribution do |contribution|
      !user.id.nil? and !contribution.project.contributions.find_by_user_id(user.id).nil?
    end

    # Groups
    can :read, Group
    can [:create, :new_add, :submit_add], Group if user.id
    can :remove_project, Group # had to move check for admin or project owner to controller

    can [:update, :admin, :add_list, :destroy], Group, admin_user: user

    #Aprovals
    can [:approve, :reject], Approval do |a|
      a.group.admin_user == user
    end

    #Lists
    can :read, List
    can [:destroy, :update, :sort, :add_listing], List do |l|
      if l.listable_type == "Group"
        l.listable.admin_user == user
      elsif l.listable_type == "User"
        l.listable.id == user.id
      else
        false
      end
    end

  end
end
