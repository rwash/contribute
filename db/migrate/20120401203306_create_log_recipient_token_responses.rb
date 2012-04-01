class CreateLogRecipientTokenResponses < ActiveRecord::Migration
  def change
    create_table :log_recipient_token_responses do |t|
			t.string :refundTokenID
			t.string :tokenID
			t.string :status
			t.string :callerReference
			
			t.string :errorMessage
    	t.timestamps
    end
  end
end
