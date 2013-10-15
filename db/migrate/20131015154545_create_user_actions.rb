class CreateUserActions < ActiveRecord::Migration
  def change
    create_table :user_actions do |t|
      t.integer :user_id
      t.string :subject_type
      t.integer :subject_id
      t.string :event
      t.text :message

      t.timestamps
    end
  end
end
