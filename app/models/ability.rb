class Ability
  include CanCan::Ability

  def initialize(user)
		can :read, Project, :active => true

		unless user.nil?
			can :create, Project
			can :update, Project, :active => true, :user_id => user.id
		else
			cannot [:create, :update], Project
		end
 end
end
