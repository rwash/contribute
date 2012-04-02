class CreateLogCancelRequests < ActiveRecord::Migration
  def change
    create_table :log_cancel_requests do |t|
			t.string :TokenId			

      t.timestamps
    end
  end
end
