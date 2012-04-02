class CreateLogPayResponses < ActiveRecord::Migration
  def change
    create_table :log_pay_responses do |t|
			t.string :TransactionId
			t.string :TransactionStatus
			t.string :RequestId
      t.timestamps
    end
  end
end
