class Ability
  include CanCan::Ability

  def initialize(user)
		user ||= User.new

		# Projects
		can :read, Project do |p|
			p.public_can_view? || p.user_id == user.id
		end
		can :create, Project
		can :update, Project do |p|
			p.user_id == user.id and p.can_edit?
		end
		can :activate, Project, :user_id => user.id
		
		can :destroy, Project, :user_id => user.id
		can :save, Project
		can :upload, Project
		
		# Contributions
		# Make sure the user isn't a project owner and doesn't have a contribution already
		can :contribute, Project do |project|
			!user.id.nil? and project.user_id != user.id and project.contributions.find_by_user_id(user.id).nil? and project.end_date >= Date.today
		end
		# If the user is logged in, doesn't own the project,  and has a contribution on this project,
		# they can edit
		can :edit_contribution, Project do |project|
			!user.id.nil? and !project.contributions.find_by_user_id(user.id).nil?
		end
		
		# Groups
		can :read, Group
		can :create, Group
		can :new_approval, Group
		can :open_add, Group
		can :edit, Group, :admin_user_id => user.id
		can :update, Group, :admin_user_id => user.id
		can :admin, Group, :admin_user_id => user.id
		
		#Aprovals
		can :approve, Approval do |a|
			Group.find(a.group_id).admin_user_id == user.id
		end
		can :reject, Approval do |a|
			Group.find(a.group_id).admin_user_id == user.id
		end
		
	end
end
