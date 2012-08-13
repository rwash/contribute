class Item < ActiveRecord::Base
	belongs_to :list
	acts_as_list :scope => :list
	
	belongs_to :itemable, :polymorphic => true
	paginates_per 8
end