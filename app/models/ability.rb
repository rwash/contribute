class Ability
  include CanCan::Ability

  def initialize(user)
		user ||= User.new

		# Projects
		can :read, Project do |p|
			p.public_can_view? or p.user_id == user.id or p.confirmation_approver?
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
		can :new_add, Group
		can :submit_add, Group
		can :edit, Group, :admin_user_id => user.id
		can :update, Group, :admin_user_id => user.id
		can :admin, Group, :admin_user_id => user.id
		can :remove_project, Group # had to move check for admin or proeject owner to controller
		can :add_list, Group, :admin_user_id => user.id
		can :destroy, Group, :admin_user_id => user.id
		
		#Aprovals
		can :approve, Approval do |a|
			Group.find(a.group_id).admin_user_id == user.id
		end
		can :reject, Approval do |a|
			Group.find(a.group_id).admin_user_id == user.id
		end
		
		#Lists (Find a way to make it cleaner/shorter?)
		can :read, List
		can :destroy, List do |l|
			if l.listable_type == "Group"
				l.listable.admin_user_id == user.id
			elsif l.listable_type == "User"
				l.listable.id == user.id
			else
				false
			end
		end
		can :edit, List do |l|
			if l.listable_type == "Group"
				l.listable.admin_user_id == user.id
			elsif l.listable_type == "User"
				l.listable.id == user.id
			else
				false
			end
		end
		can :update, List do |l|
			if l.listable_type == "Group"
				l.listable.admin_user_id == user.id
			elsif l.listable_type == "User"
				l.listable.id == user.id
			else
				false
			end
		end
		can :sort, List do |l|
			if l.listable_type == "Group"
				l.listable.admin_user_id == user.id
			elsif l.listable_type == "User"
				l.listable.id == user.id
			else
				false
			end
		end
		can :add_item, List do |l|
			if l.listable_type == "Group"
				l.listable.admin_user_id == user.id
			elsif l.listable_type == "User"
				l.listable.id == user.id
			else
				false
			end
		end
		
		
  end
end
