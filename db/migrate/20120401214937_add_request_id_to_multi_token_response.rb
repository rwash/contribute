class AddRequestIdToMultiTokenResponse < ActiveRecord::Migration
  def change
    add_column :log_multi_token_responses, :log_multi_token_request_id, :integer
    remove_column :log_multi_token_responses, :callerReference
  end
end
