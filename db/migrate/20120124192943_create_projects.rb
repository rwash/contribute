class CreateProjects < ActiveRecord::Migration
  def up
    create_table :projects do |t|
			t.string :name
			t.string :short_description
			t.text	:long_description
			t.integer :funding_goal
			t.date :end_date
			t.integer :category_id
			t.boolean :active

      t.timestamps
    end
  end

	def down
		drop_table :projects
	end
end
