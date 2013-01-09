class AddStatusToContributions < ActiveRecord::Migration
  def change
    add_column :contributions, :status, :integer
    add_column :contributions, :retry_count, :integer

    remove_column :contributions, :cancelled
    remove_column :contributions, :complete
    remove_column :contributions, :waiting_cancellation
  end
end
