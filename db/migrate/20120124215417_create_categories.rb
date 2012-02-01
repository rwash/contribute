class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :short_description
      t.text :long_description

      t.timestamps
    end
  end
end
