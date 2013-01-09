class CreateLogMultiTokenResponses < ActiveRecord::Migration
  def change
    create_table :log_multi_token_responses do |t|
      t.string :tokenID
      t.string :status
      t.string :callerReference

      t.string :errorMessage
      t.string :warningCode
      t.string :warningMessage
      t.timestamps
    end
  end
end
