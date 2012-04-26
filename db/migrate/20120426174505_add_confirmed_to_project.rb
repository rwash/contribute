class AddConfirmedToProject < ActiveRecord::Migration
  def change
    add_column :projects, :confirmed, :boolean
  end
end
