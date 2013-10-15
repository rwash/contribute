class CreateUserActions < ActiveRecord::Migration
  def change
    create_table :user_actions do |t|
      t.integer :user_id
      t.string :object_type
      t.integer :object_id
      t.string :event
      t.text :message

      t.timestamps
    end
  end
end
