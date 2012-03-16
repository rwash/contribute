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
