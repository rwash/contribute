class CreatePageViews < ActiveRecord::Migration
  def change
    create_table :page_views do |t|
      t.integer :user_id
      t.string :ip
      t.string :controller
      t.string :action
      t.text :parameters

      t.timestamps
    end
  end
end
