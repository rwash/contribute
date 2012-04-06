class AddStatusToContributions < ActiveRecord::Migration
  def change
		add_column :contributions, :contribution_status_id, :integer
		add_column :contributions, :retry_count, :integer

		remove_column :contributions, :cancelled
		remove_column :contributions, :complete
		remove_column :contributions, :waiting_cancellation

		create_table :contribution_statuses do |t|
			t.integer :id
			t.string :name
		end
  end
end
