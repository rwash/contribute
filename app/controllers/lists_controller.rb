class ListsController < InheritedResources::Base
  load_and_authorize_resource
  before_filter :authenticate_user!, only: [ :new, :create, :edit, :update, :destroy, :save]

  def sort
    @list = List.find(params[:id])
    @list.title = params[:title].to_s
    @list.save!

    @listing = @list.listings.order("position DESC")
    @listings.each do |listing|
      # TODO wat. Look into using the listable gem helper functions
      listing.position = params['listing'].index(listing.id.to_s) + 1
      listing.save
    end
    render nothing: true
  end

  # TODO This should not all be done manually. We should be using
  # the update_attributes method that ActiveRecord provides
  def update
    @list = List.find(params[:id])
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
      flash[:error] = "Failed to delete list. Please try again."
    end
    redirect_to @list.listable
  end

  def edit
    @list = List.find(params[:id])
    return redirect_to @list.listable if @list.permanent?

    if current_user and current_user.admin
      @projects = [:active,:funded,:nonfunded].map { |state| Project.find_all_by_state(state) }.flatten
    else
      @projects = [:active, :funded, :nonfunded].map { |state| @list.listable.projects.find_all_by_state(state) }.flatten
    end
    @source = []
    for project in @projects
      #@source  << "#{project.name} - #{project.state}"
      @source  << project.name
    end
  end

  def add_listing
    @list = List.find(params[:id])
    @project = Project.find_by_name(params[:project])
    @list.listings << Listing.create(project_id: @project.id)

    redirect_to :back
  end

  def show
    @list = List.find(params[:id])
    @group = @list.listable if @list.listable_type == 'Group'
    @projects = @list.sorted_projects
    if @projects.class.name == 'Array'
      @projects = Kaminari.paginate_array(@projects).page(params[:page]).per(12)
    else
      @projects = @projects.page(params[:page]).per(12)
    end

  end
end
