class MakeWaitingCancellationAnInt < ActiveRecord::Migration
  def change
		change_column :contributions, :waiting_cancellation, :integer
  end
end
