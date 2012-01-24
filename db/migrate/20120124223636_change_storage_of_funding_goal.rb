class ChangeStorageOfFundingGoal < ActiveRecord::Migration
  def change 
		remove_column :projects, :fundingGoal

		add_column :projects, :fundingGoal, :decimal, :precision => 8, :scale => 2
  end
end
