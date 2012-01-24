class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :shortDescription
      t.text :longDescription

      t.timestamps
    end
  end
end
