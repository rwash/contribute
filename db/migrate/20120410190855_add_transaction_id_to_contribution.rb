class AddTransactionIdToContribution < ActiveRecord::Migration
  def change
    add_column :contributions, :transaction_id, :string
  end
end
