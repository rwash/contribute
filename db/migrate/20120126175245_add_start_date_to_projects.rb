class AddStartDateToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :startDate, :datetime
  end

  def self.down
    remove_column :projects, :startDate
  end
end
