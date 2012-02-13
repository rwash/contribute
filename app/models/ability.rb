class Ability
  include CanCan::Ability

  def initialize(user)
		#Projects
		can :read, Project, :active => true
		if user.nil?
			cannot [:create, :update], Project
		else
			can [:create, :update], Project, :active => true, :user_id => user.id
		end
		cannot :destroy, Project
		
		#I'm going to leave the below comments for reference.  Once we're confident we can get rid of them
		#
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
