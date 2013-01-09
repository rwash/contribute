class CreateLogPayRequests < ActiveRecord::Migration
  def change
    create_table :log_pay_requests do |t|
      t.string :CallerReference
      t.string :RecipientTokenId
      t.string :SenderTokenId

      t.timestamps
    end
  end
end
