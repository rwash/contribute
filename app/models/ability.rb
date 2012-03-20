class Ability
  include CanCan::Ability

  def initialize(user)
		user ||= User.new

		#Projects
		can :read, Project, :active => true
		can :create, Project
		can :update, Project, :active => true, :user_id => user.id
		can :save, Project

		#Contributions
		# If the user is anonymous, return true,
		# else, make sure the user isn't a project owner and doesn't have a contribution already
		can :contribute, Project do |project|
			if !user.id.nil?
				project.user_id != user.id and project.contributions.find_by_user_id(user.id).nil?
			else
				true #He can contribute, because he's anonymous
			end
		end
		# If the user is logged in, doesn't own the project,  and has a contribution on this project,
		# they can edit
		can :edit_contribution, Project do |project|
			!user.id.nil? and !project.contributions.find_by_user_id(user.id).nil?
		end

		can :update, Contribution do |contribution|
			!user.id.nil? and contribution.user_id == user.id
		end
	end
end
