class CreateProjects < ActiveRecord::Migration
  def up
    create_table :projects do |t|
			t.string :name
			t.string :shortDescription
			t.text	:longDescription
			t.decimal :fundingGoal
			t.date :startDate
			t.date :endDate

      t.timestamps
    end
  end

	def down
		drop_table :projects
	end
end
