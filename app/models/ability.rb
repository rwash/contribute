# The Ability class defines what a user can or cannot do throughout the site.
#
# The class includes the CanCan::Ability module, defined in Ryan Bates' CanCan gem.
# The CanCan gem can be found at http://github.com/ryanb/cancan
class Ability
  include CanCan::Ability

  # Sets up user permissions (abilities)
  def initialize(user)
    define_global_privileges
    define_user_privileges(user) if user
    define_admin_privileges(user) if user and user.admin?
  end

  # Define basic privileges that are granted to everyone,
  # even when they aren't signed in
  def define_global_privileges
    can :read, Project, public_can_view?: true
    can :index, Project
    can :read, Group
  end

  # If the user is signed in, they get additional privileges
  def define_user_privileges(user)
    # Projects
    can :create, Project
    can [:read, :save, :activate], Project, owner: user
    can :read, Project do |project|
      project.confirmation_approver? user
    end

    can :destroy, Project, owner: user, state: :active
    can :destroy, Project, owner: user, state: :inactive
    can :destroy, Project, owner: user, state: :unconfirmed

    # Note: this 'update' refers to the Update and Edit actions of ProjectsController,
    # not the ability to create Update objects associated with a project
    can :update, Project, owner: user, can_edit?: true

    can :create, Update do |update|
      update.project.can_update? and
        update.project.owner == user
    end

    can :destroy, Video do |video|
      video.project.owner = user
    end

    can :create, Comment if user.id
    can :destroy, Comment do |comment|
      comment.user == user and comment.body != "comment deleted"
    end

    can :create, Contribution do |contribution|
      contribution.project.owner != user and
        contribution.project.contributions.find_by_user_id(user.id).nil? and
        contribution.project.end_date >= Time.zone.today
    end
    # If the user is logged in, doesn't own the project,  and has a contribution on this project,
    # they can edit
    can :update, Contribution do |contribution|
      !contribution.project.contributions.find_by_user_id(user.id).nil?
    end

    # Groups
    can [:create], Group
    can :remove_project, Group # had to move check for admin or project owner to controller

    can [:update, :admin, :destroy], Group, owner: user

    #Aprovals
    can :create, Approval
    can [:approve, :reject], Approval do |approval|
      approval.group.owner == user
    end

    can :read, User, id: user.id
  end

  def define_admin_privileges(user)
    # Even more privileges if you're a site admin!
    if user and user.admin?
      # Projects
      can :read, Project
      # TODO change this to 'cancel'
      can :destroy, Project, owner: user, state: :active
      can :destroy, Project, state: :inactive
      can :destroy, Project, state: :unconfirmed

      # Note: this 'update' refers to the Update and Edit actions of ProjectsController,
      # not the ability to create Update objects associated with a project
      can :update, Project, owner: user, can_edit?: true

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
      can [:read, :create, :remove_project], Group # had to move check for admin or project owner to controller
      can [:update, :admin, :destroy], Group

      #Aprovals
      can [:create, :approve, :reject], Approval

      # Users
      can [:read, :update, :toggle_admin], User
    end
  end
end
