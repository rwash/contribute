class ChangeDataTypeForStartDate < ActiveRecord::Migration
  def self.up
	change_table :projects do |t|
		t.change :startDate, :date
	end
  end

  def self.down
	change_table :projects do |t|
		t.change :startDate, :datetime
	end
  end
end
