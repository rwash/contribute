class AddRequestIdToLogGetTransactionResponse < ActiveRecord::Migration
  def change
		add_column :log_get_transaction_responses, :RequestId, :string
  end
end
