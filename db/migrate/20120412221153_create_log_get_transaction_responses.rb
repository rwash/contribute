class CreateLogGetTransactionResponses < ActiveRecord::Migration
  def change
    create_table :log_get_transaction_responses do |t|
			t.string :TransactionId
			t.string :TransactionStatus
			t.string :CallerReference
			t.string :StatusCode
			t.string :StatusMessage
      t.timestamps
    end
  end
end
