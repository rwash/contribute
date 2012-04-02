class CreateLogErrors < ActiveRecord::Migration
  def change
  	create_table :log_errors do |t|
			t.integer :request_id
			t.string :Code
			t.string :Message

      t.timestamps
    end
  end
end
