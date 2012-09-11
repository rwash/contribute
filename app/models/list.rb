class List < ActiveRecord::Base
	LIST_KINDS = %w[default manual created-at-descending created-at-ascending end-date-descending end-date-ascending funding-goal-descending funding-goal-ascending amount-left-to-goal-in-dollars-descending amount-left-to-goal-in-dollars-ascending amount-left-to-goal-as-percent-descending amount-left-to-goal-as-percent-ascending amount-donated-in-dollars-descending amount-donated-in-dollars-ascending amount-donated-as-percent-of-goal-descending amount-donated-as-percent-of-goal-ascending random-descending random-ascending]

	has_many :items, :order => "position"
	belongs_to :listable, :polymorphic => true
	validate :validate_kind
	
	validates :listable_id, :presence => true
	validates :listable_type, :presence => true
	
	def validate_kind
		errors.add(:kind, "Invalid value for kind, check list.rb") unless LIST_KINDS.include?(self.kind)
	end
	
	#pass in the number of projects you want
	def get_projects_in_order(limit = Project.count)
		@projects = []
		unless self.listable_type == "User" and self.listable.id == 1
			@projects << self.listable.projects.where(:state => "active") if self.show_active
			@projects << self.listable.projects.where(:state => "funded") if self.show_funded
			@projects << self.listable.projects.where(:state => "nonfunded") if self.show_nonfunded
		else
			@projects << Project.where("state = ?", "active") if self.show_active
			@projects << Project.where("state = ?", "funded") if self.show_funded
			@projects << Project.where("state = ?", "nonfunded") if self.show_nonfunded
		end
		@projects.flatten!
		
		case self.kind
		when "manual"
			@projects = []
			for item in self.items.order("position DESC").limit(limit)
				@projects << item.itemable
			end
			@projects
		when "created-at-descending"
			@projects.sort {|a,b| b.created_at <=> a.created_at }.slice!(0,limit)
		when "created-at-ascending"
			@projects.sort {|a,b| a.created_at <=> b.created_at }.slice!(0,limit)
		when "end-date-descending"
			@projects.sort {|a,b| b.end_date <=> a.end_date }.slice!(0,limit)
		when "end-date-ascending"
			@projects.sort {|a,b| a.end_date <=> b.end_date }.slice!(0,limit)
		when "funding-goal-descending"
			@projects.sort {|a,b| b.funding_goal <=> a.funding_goal }.slice!(0,limit)
		when "funding-goal-ascending"
			@projects.sort {|a,b| a.funding_goal <=> b.funding_goal }.slice!(0,limit)
		when "amount-left-to-goal-in-dollars-descending"
			@projects.sort {|a,b| b.left_to_goal <=> a.left_to_goal }.slice!(0,limit)
		when "amount-left-to-goal-in-dollars-ascending"
			@projects.sort {|a,b| a.left_to_goal <=> b.left_to_goal }.slice!(0,limit)
		when "amount-left-to-goal-as-percent-descending"
			@projects.sort {|a,b| a.contributions_percentage <=> b.contributions_percentage }.slice!(0,limit)
		when "amount-left-to-goal-as-percent-ascending"
			@projects.sort {|a,b| b.contributions_percentage <=> a.contributions_percentage }.slice!(0,limit)
		when "amount-donated-in-dollars-descending"
			@projects.sort {|a,b| b.contributions_total <=> a.contributions_total }.slice!(0,limit)
		when "amount-donated-in-dollars-ascending"
			@projects.sort {|a,b| a.contributions_total <=> b.contributions_total }.slice!(0,limit)
		when "amount-donated-as-percent-of-goal-descending"
			@projects.sort {|a,b| b.contributions_percentage <=> a.contributions_percentage }.slice!(0,limit)
		when "amount-donated-as-percent-of-goal-ascending"
			@projects.sort {|a,b| a.contributions_percentage <=> b.contributions_percentage }.slice!(0,limit)
		when "random-descending"
			@projects.shuffle.slice!(0,limit)
		when "random-ascending"
			@projects.shuffle.slice!(0,limit)
		else #default
			@projects.sort {|a,b| b.created_at <=> a.created_at }.slice!(0,limit)
		end

	end
end