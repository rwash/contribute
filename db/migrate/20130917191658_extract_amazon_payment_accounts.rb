class ExtractAmazonPaymentAccounts < ActiveRecord::Migration
  def up
    create_table :amazon_payment_accounts do |t|
      t.integer :project_id
      t.string :token
      t.timestamps
    end
    remove_column :projects, :payment_account_id
  end

  def down
    drop_table :amazon_payment_accounts
    add_column :projects, :payment_account_id, :string
  end
end
