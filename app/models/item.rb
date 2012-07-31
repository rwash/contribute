class Item < ActiveRecord::Base
	belongs_to :list
  acts_as_list :scope => :list
  
  validate :valid_state
  
  self.abstract_class = true
  
  def valid_state
		errors.add(:state, "Invalid value for state var. State must be unconfirmed, inactive, active, funded, nonfunded, or canceled. Check config/enviroment.rb") unless PROJ_STATES.include?(self.state)
	end
end