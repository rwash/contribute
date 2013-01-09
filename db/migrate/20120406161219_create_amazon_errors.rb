class CreateAmazonErrors < ActiveRecord::Migration
  def change
    create_table :amazon_errors do |t|
      t.string :description
      t.text :message
      t.binary :retriable
      t.binary :email_user
      t.binary :email_admin
      t.timestamps
    end
  end
end
