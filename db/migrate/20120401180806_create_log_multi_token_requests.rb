class CreateLogMultiTokenRequests < ActiveRecord::Migration
  def change
    create_table :log_multi_token_requests do |t|
			t.string :callerReference
			t.string :recipientTokenList
			t.integer :globalAmountLimit
			t.string :paymentReason
      t.timestamps
    end
  end
end
