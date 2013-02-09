# The Ability class defines what a user can or cannot do throughout the site.
#
# The class includes the CanCan::Ability module, defined in Ryan Bates' CanCan gem.
# The CanCan gem can be found at http://github.com/ryanb/cancan
class Ability
  include CanCan::Ability

  # Sets up user permissions (abilities)
  def initialize(user)
    # Basic privileges that are granted to everyone,
    # even when they aren't signed in
    can :read, Project, public_can_view?: true
    can :read, Group
    can :read, List

    # You get more privileges once you sign in
    if user
      # Projects
      can :create, Project
      can [:read, :save, :activate], Project, user: user
      can :read, Project, confirmation_approver?: true

      can :destroy, Project, user: user, state: :inactive
      can :destroy, Project, user: user, state: :unconfirmed

      # Note: this 'update' refers to the Update and Edit actions of ProjectsController,
      # not the ability to create Update objects associated with a project
      can :update, Project, user: user, can_edit?: true

      # Updates
      can :create, Update do |update|
        update.project.can_update? and
          update.project.user == user
      end

      # Videos
      can :destroy, Video do |video|
        video.project.user = user
      end

      # Comments
      can :create, Comment if user.id
      can :destroy, Comment do |comment|
        comment.user == user and comment.body != "comment deleted"
      end

      # Contributions
      # Make sure the user isn't a project owner and doesn't have a contribution already
      can :create, Contribution do |contribution|
        contribution.project.user != user and
          contribution.project.contributions.find_by_user_id(user.id).nil? and
          contribution.project.end_date >= Time.zone.today
      end
      # If the user is logged in, doesn't own the project,  and has a contribution on this project,
      # they can edit
      can :update, Contribution do |contribution|
        !contribution.project.contributions.find_by_user_id(user.id).nil?
      end

      # Groups
      can [:create, :new_add, :submit_add], Group
      can :remove_project, Group # had to move check for admin or project owner to controller

      can [:update, :admin, :add_list, :destroy], Group, admin_user: user

      #Aprovals
      can [:approve, :reject], Approval do |approval|
        approval.group.admin_user == user
      end

      #Lists
      can [:destroy, :update, :sort, :add_listing], List do |l|
        if l.listable_type == "Group"
          l.listable.admin_user == user
        elsif l.listable_type == "User"
          l.listable.id == user.id
        else
          false
        end
      end

      can :read, User, id: user.id
    end
    # Even more privileges if you're a site admin!
    if user and user.admin?
      # Projects
      can [:read, :create, :save, :activate], Project
      can :destroy, Project, state: :inactive
      can :destroy, Project, state: :unconfirmed

      # Note: this 'update' refers to the Update and Edit actions of ProjectsController,
      # not the ability to create Update objects associated with a project
      can :update, Project, can_edit?: true

      # Updates
      can :create, Update do |update|
        update.project.can_update?
      end

      # Videos
      can :destroy, Video

      # Comments
      can :create, Comment if user.id
      can :destroy, Comment do |comment|
        comment.body != "comment deleted"
      end

      # Contributions
      # Make sure the user isn't a project owner and doesn't have a contribution already
      can :create, Contribution do |contribution|
        contribution.project.contributions.find_by_user_id(user.id).nil? and
          contribution.project.end_date >= Time.zone.today
      end
      # If the user is logged in, doesn't own the project,  and has a contribution on this project,
      # they can edit
      can :update, Contribution do |contribution|
        # TODO clean this up...
        !contribution.project.contributions.find_by_user_id(user.id).nil?
      end

      # Groups
      can [:read, :create, :new_add, :submit_add, :remove_project], Group # had to move check for admin or project owner to controller
      can [:update, :admin, :add_list, :destroy], Group

      #Aprovals
      can [:approve, :reject], Approval

      #Lists
      can [:read, :destroy, :update, :sort, :add_listing], List

      # Users
      can [:read, :update, :block, :toggle_admin], User
    end
  end
end
