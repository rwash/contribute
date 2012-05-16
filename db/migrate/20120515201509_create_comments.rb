class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :userid
      t.text :content
      t.integer :parentid

      t.timestamps
    end
  end
end
