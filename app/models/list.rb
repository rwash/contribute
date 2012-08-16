class List < ActiveRecord::Base
	LIST_KINDS = %w[default manual created-at-desc created-at-asc end-date-desc end-date-asc funding-goal-desc funding-goal-asc amount-left-to-goal-in-dollars-desc amount-left-to-goal-in-dollars-asc amount-left-to-goal-as-percent-desc amount-left-to-goal-as-percent-asc amount-donated-in-dollars-desc amount-donated-in-dollars-asc amount-donated-as-percent-of-goal-desc amount-donated-as-percent-of-goal-asc random-desc random-asc]

	has_many :items, :order => "position"
	belongs_to :listable, :polymorphic => true
	validate :validate_kind
	
	def validate_kind
		errors.add(:kind, "Invalid value for kind, check list.rb") unless LIST_KINDS.include?(self.kind)
	end
	
	#pass in the number of projects you want
	def get_projects_in_order(limit = self.listable.projects.size)
		case self.kind
		when "manual"
			@projects = []
			for item in self.items.order("position DESC").limit(limit)
				@projects << item.itemable
			end
			@projects
		when "created-at-desc"
			self.listable.projects.order("created_at DESC").limit(limit)
		when "created-at-asc"
			self.listable.projects.order("created_at ASC").limit(limit)
		when "end-date-desc"
			self.listable.projects.order("end_date DESC").limit(limit)
		when "end-date-asc"
			self.listable.projects.order("end_date ASC").limit(limit)
		when "funding-goal-desc"
			self.listable.projects.order("funding_goal DESC").limit(limit)
		when "funding-goal-asc"
			self.listable.projects.order("funding_goal ASC").limit(limit)
		when "amount-left-to-goal-in-dollars-desc"
			self.listable.projects.sort {|a,b| b.left_to_goal <=> a.left_to_goal }.slice!(0,limit)
		when "amount-left-to-goal-in-dollars-asc"
			self.listable.projects.sort {|a,b| a.left_to_goal <=> b.left_to_goal }.slice!(0,limit)
		when "amount-left-to-goal-as-percent-desc"
			self.listable.projects.sort {|a,b| a.contributions_percentage <=> b.contributions_percentage }.slice!(0,limit)
		when "amount-left-to-goal-as-percent-asc"
			self.listable.projects.sort {|a,b| b.contributions_percentage <=> a.contributions_percentage }.slice!(0,limit)
		when "amount-donated-in-dollars-desc"
			self.listable.projects.sort {|a,b| b.contributions_total <=> a.contributions_total }.slice!(0,limit)
		when "amount-donated-in-dollars-asc"
			self.listable.projects.sort {|a,b| a.contributions_total <=> b.contributions_total }.slice!(0,limit)
		when "amount-donated-as-percent-of-goal-desc"
			self.listable.projects.sort {|a,b| b.contributions_percentage <=> a.contributions_percentage }.slice!(0,limit)
		when "amount-donated-as-percent-of-goal-asc"
			self.listable.projects.sort {|a,b| a.contributions_percentage <=> b.contributions_percentage }.slice!(0,limit)
		when "random-desc"
			self.listable.projects.order("RAND()").limit(limit)
		when "random-asc"
			self.listable.projects.order("RAND()").limit(limit)
		else #default
			self.listable.projects.order("created_at DESC").limit(limit)
		end
	end
end