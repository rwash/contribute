class Ability
  include CanCan::Ability

  def initialize(user)
		user ||= User.new
		can :read, Project, :active => true
		can :create, Project
		can :update, Project, :active => true, :user_id => user.id
 end
end
