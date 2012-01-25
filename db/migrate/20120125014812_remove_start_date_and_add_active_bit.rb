class RemoveStartDateAndAddActiveBit < ActiveRecord::Migration
  def change
		remove_column :projects, :startDate

		add_column :projects, :active, :boolean
  end
end
