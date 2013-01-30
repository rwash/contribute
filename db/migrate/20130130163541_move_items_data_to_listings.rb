class MoveItemsDataToListings < ActiveRecord::Migration
  def up
    Item.all.each do |item|
      unless item.itemable_type == "Project"
        raise "Found item with itemable_type = #{item.itemable_type} (expected: 'Project')\n#{item.inspect}"
      end

      Listing.create(list_id: item.list_id,
                     project_id: item.itemable_id,
                     position: item.position,
                     created_at: item.created_at,
                     updated_at: item.updated_at)
    end
  end

  def down
    Listing.all.each do |listing|
      Listing.create(list_id: listing.list_id,
                     itemable_id: listing.project_id,
                     itemable_type: "Project",
                     position: listing.position,
                     created_at: listing.created_at,
                     updated_at: listing.updated_at)
    end
  end
end
