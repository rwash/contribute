class Ability
  include CanCan::Ability

  def initialize(user)
		user ||= User.new

		#Projects
		can :read, Project, :active => true, :confirmed => true
		can :create, Project
		can :update, Project, :active => true, :user_id => user.id
		can :destroy, Project, :active => true, :confirmed => true, :user_id => user.id
		can :save, Project

		#Contributions
		# Make sure the user isn't a project owner and doesn't have a contribution already
		can :contribute, Project do |project|
			!user.id.nil? and project.user_id != user.id and project.contributions.find_by_user_id(user.id).nil?
		end
		# If the user is logged in, doesn't own the project,  and has a contribution on this project,
		# they can edit
		can :edit_contribution, Project do |project|
			!user.id.nil? and !project.contributions.find_by_user_id(user.id).nil?
		end
	end
end
