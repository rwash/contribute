class CreateUpdates < ActiveRecord::Migration
  def change
    create_table :updates do |t|
      t.text :content
      t.integer :userid

      t.timestamps
    end
  end
end
