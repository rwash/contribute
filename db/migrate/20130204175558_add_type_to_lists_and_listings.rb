class AddTypeToListsAndListings < ActiveRecord::Migration
  def change
    add_column :lists, :type, :string, default: 'ProjectList'

    add_column :listings, :type, :string, default: 'ProjectListing'
  end
end
