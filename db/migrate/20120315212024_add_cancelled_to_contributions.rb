class AddCancelledToContributions < ActiveRecord::Migration
  def change
    add_column :contributions, :cancelled, :binary
  end
end
