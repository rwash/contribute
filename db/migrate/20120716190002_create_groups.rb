class CreateGroups < ActiveRecord::Migration
  def up
  	create_table :groups do |t|
			t.string :name, :default => ''
			t.string :description, :default => ''
			t.boolean :open, :default => 0
			t.integer :admin_user_id
			
			t.string :picture_file_name
			t.string :picture_content_type
			t.integer :picture_file_size
			t.datetime :picture_updated_at

      t.timestamps
    end
  end

  def down
  	drop_table :groups
  end
end
