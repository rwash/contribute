class AddConfirmationToContributions < ActiveRecord::Migration
  def change
    add_column :contributions, :confirmed, :boolean, :default => false
  end
end
