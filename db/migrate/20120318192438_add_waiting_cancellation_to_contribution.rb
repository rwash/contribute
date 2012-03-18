class AddWaitingCancellationToContribution < ActiveRecord::Migration
  def change
    add_column :contributions, :waiting_cancellation, :binary
  end
end
