class AddPaymentIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :payment_account_id, :string
  end
end
