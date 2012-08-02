class ItemsController < InheritedResources::Base
	def sort
		@group = Group.find_by_id(params[:id])
		@items = @group.lists.first.items.order("position DESC")
		@items.each do |item|
			item.position = params['item'].index(item.id.to_s) + 1
			item.save
		end
		render :nothing => true
	end
end