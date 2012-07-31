class Item < ActiveRecord::Base
	belongs_to :list
  acts_as_list :scope => :list
  
  self.abstract_class = true
  
end