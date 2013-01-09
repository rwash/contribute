class ChangeBinaryTypeAmazonErrors < ActiveRecord::Migration
  def up
    change_column :amazon_errors, :retriable, :boolean
    change_column :amazon_errors, :email_user, :boolean
    change_column :amazon_errors, :email_admin, :boolean
  end

  def down
    change_column :amazon_errors, :retriable, :binary
    change_column :amazon_errors, :email_user, :binary
    change_column :amazon_errors, :email_admin, :binary
  end
end
