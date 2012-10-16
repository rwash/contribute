class ListsController < InheritedResources::Base
	load_and_authorize_resource
	before_filter :authenticate_user!, :only => [ :new, :create, :edit, :update, :destroy, :save]
	
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
	
	def update
		@list = List.find_by_id(params[:id])
		@list.kind = "#{params[:kind].gsub(/\W/, '-')}"
		@list.kind += "-#{params[:order]}" unless @list.kind == 'manual'
		@list.title = params[:title]
		@list.show_active = params[:showActive]
		@list.show_funded = params[:showFunded]
		@list.show_nonfunded = params[:showNonfunded]
		@list.save!
		
		redirect_to @list.listable
	end
	
	def destroy
		@list = List.find(params[:id])
		unless @list.destroy
			flash[:error] = "Failed to delete list."
		end
		redirect_to @list.listable
	end
	
	def edit
		@list = List.find(params[:id])
		return redirect_to @list.listable if @list.permanent?
		
		if !current_user.nil? and current_user.admin
			@projects = Project.where("state = ? OR state = ? OR state = ?", 'active', 'funded', 'nonfunded')
		else
			@projects = @list.listable.projects.where("state = ? OR state = ? OR state = ?", 'active', 'funded', 'nonfunded')
		end
		@source = []
		for project in @projects
			#@source  << "#{project.name} - #{project.state}"
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
		@group = @list.listable if @list.listable_type == 'Group'
		@projects = get_projects_in_order(@list)
		if @projects.class.name == 'Array'
			@projects = Kaminari.paginate_array(@projects).page(params[:page]).per(12)
		else
			@projects = @projects.page(params[:page]).per(12)
		end
		
	end
end