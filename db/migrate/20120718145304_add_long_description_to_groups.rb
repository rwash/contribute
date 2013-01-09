class AddLongDescriptionToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :long_description, :string
  end
end
