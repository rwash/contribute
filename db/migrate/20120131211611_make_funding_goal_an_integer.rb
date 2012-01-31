class MakeFundingGoalAnInteger < ActiveRecord::Migration
  def change 
		remove_column :projects, :fundingGoal
		add_column :projects, :fundingGoal, :integer
  end
end
