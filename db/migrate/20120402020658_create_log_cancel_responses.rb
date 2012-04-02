class CreateLogCancelResponses < ActiveRecord::Migration
  def change
    create_table :log_cancel_responses do |t|
			t.integer :log_cancel_request_id
			t.string :RequestId
      t.timestamps
    end
  end
end
