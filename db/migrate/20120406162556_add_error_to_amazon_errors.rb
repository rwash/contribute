class AddErrorToAmazonErrors < ActiveRecord::Migration
  def up
    add_column :amazon_errors, :error, :string
  end

  def down
    remove_column :amazon_errors, :error
  end
end
