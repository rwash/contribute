class AddTypeToPaymentAccount < ActiveRecord::Migration
  def change
    add_column :amazon_payment_accounts, :type, :string
  end
end
