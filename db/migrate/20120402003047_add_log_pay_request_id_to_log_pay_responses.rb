class AddLogPayRequestIdToLogPayResponses < ActiveRecord::Migration
  def change
    add_column :log_pay_responses, :log_pay_request_id, :integer
  end
end
