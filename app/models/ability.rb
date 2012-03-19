class Ability
  include CanCan::Ability

  def initialize(user)
		user ||= User.new

		#Projects
		can :read, Project, :active => true
		can :create, Project
		can :update, Project, :active => true, :user_id => user.id
		can :save, Project

		#If the user is anonymous, return true,
		#else, make sure the user isn't a project owner and doesn't have a contribution already
		can :contribute, Project do |project|
			unless user.id.nil?
				project.user_id != user.id and project.contributions.find_by_user_id(user.id).nil?
			else
				true
			end
		end

		#If the user is logged in, doesn't own the project,  and has a contribution on this project, they can edit
		can :edit_contribution, Project do |project|
			!user.id.nil? and project.user_id != user.id and !project.contributions.find_by_user_id(user.id).nil?
		end

		#Contributions
		can :create, Contribution
		can :update, Contribution do |contribution|
			unless user.id.nil?
				contribution.user_id == user.id
			else
				false
			end
		end
		#TODO: Write the criteria for when a user can create a contribution
		# E.g. if logged in, and haven't already contributed to this project and didn't create the project
		#can :create, Contribution
 end
end
