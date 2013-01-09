class ChangeAmountToInt < ActiveRecord::Migration
  def change
    change_column :contributions, :amount, :integer
  end
end
