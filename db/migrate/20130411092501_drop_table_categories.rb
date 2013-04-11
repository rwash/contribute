class DropTableCategories < ActiveRecord::Migration
  def up
    drop_table :categories

    remove_column :projects, :category_id
  end

  def down
    create_table :categories do |t|
      t.string :short_description
      t.text :long_description

      t.timestamps
    end

    add_column :projects, :category_id, :integer
  end
end
