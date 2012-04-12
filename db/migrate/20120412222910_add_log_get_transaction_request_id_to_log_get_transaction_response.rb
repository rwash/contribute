class AddLogGetTransactionRequestIdToLogGetTransactionResponse < ActiveRecord::Migration
  def change
		add_column :log_get_transaction_responses, :log_get_transaction_request_id, :integer
  end
end
