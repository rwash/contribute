class AddRequestIdToLogError < ActiveRecord::Migration
  def change
    rename_column :log_errors, :request_id, :log_request_id
    add_column :log_errors, :RequestId, :string
  end
end
