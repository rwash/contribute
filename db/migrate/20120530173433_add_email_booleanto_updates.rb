class AddEmailBooleantoUpdates < ActiveRecord::Migration
  def up
   add_column :updates, :email_sent, :boolean
  end

  def down
  end
end
