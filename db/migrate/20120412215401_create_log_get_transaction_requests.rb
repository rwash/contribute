class CreateLogGetTransactionRequests < ActiveRecord::Migration
  def change
    create_table :log_get_transaction_requests do |t|
      t.string :TransactionId
      t.timestamps
    end
  end
end
