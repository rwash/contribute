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
		can :update, Contribution, :user_id => user.id
		can :c
 end
end
