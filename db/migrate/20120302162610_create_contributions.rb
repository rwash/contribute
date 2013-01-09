class CreateContributions < ActiveRecord::Migration
  def change
    create_table :contributions do |t|
      t.string :payment_key
      t.decimal :amount
      t.integer :project_id
      t.integer :user_id
      t.binary :complete

      t.timestamps
    end
  end
end
