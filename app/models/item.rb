class Item < ActiveRecord::Base
	belongs_to :list
	acts_as_list :scope => :list
	
	has_one :thing, :as => :itemable
end