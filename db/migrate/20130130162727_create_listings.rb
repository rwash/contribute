class CreateListings < ActiveRecord::Migration
  def change
    create_table :listings do |t|
      t.integer :list_id
      t.integer :project_id
      t.integer :position

      t.timestamps
    end
  end
end
