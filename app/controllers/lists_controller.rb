class ListsController < InheritedResources::Base
	#load_and_authorize_resource
	#before_filter :authenticate_user!, :only => [ :new, :create, :edit, :update, :destroy, :save]
	
	def sort
		@list = List.find_by_id(params[:id])
		@list.title = params[:title].to_s
		@list.save!
		
		@items = @list.items.order("position DESC")
		@items.each do |item|
			item.position = params['item'].index(item.id.to_s) + 1
			item.save
		end
		render :nothing => true
	end
	
	def destroy
		@list = List.find(params[:id])
		unless @list.destroy
			flash[:error] = "Failed to delete list."
		end
		redirect_to :back
	end
	
	def edit
		@list = List.find(params[:id])
		@source = []
		for project in @list.listable.projects
			@source  << project.name
		end
	end
	
	def add_item
		@list = List.find(params[:id])
		@project = Project.find_by_name(params[:project])
		@list.items << Item.create(:itemable_id => @project.id, :itemable_type => @project.class.name)
		
		redirect_to :back
	end
	
	def show
		@list = List.find(params[:id])
		@items = @list.items.order("position DESC").page params[:page]
	end
end