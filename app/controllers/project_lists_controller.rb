class ProjectListsController < InheritedResources::Base
  load_and_authorize_resource
  before_filter :authenticate_user!, only: [ :new, :create, :edit, :update, :destroy, :save]

  # TODO This should not all be done manually. We should be using
  # the update_attributes method that ActiveRecord provides
  def update
    list = List.find(params[:id])
    list.title = params[:title]
    list.show_active = params[:showActive]
    list.show_funded = params[:showFunded]
    list.show_nonfunded = params[:showNonfunded]
    list.save!

    redirect_to list.listable
  end

  def destroy
    list = List.find(params[:id])
    flash[:error] = "Failed to delete list. Please try again." unless list.destroy
    redirect_to list.listable
  end

  def edit
    @list = List.find(params[:id])
    return redirect_to @list.listable if @list.permanent?

    @ordered_listings = @list.listings.order("position")
  end

  def add_listing
    list = List.find(params[:id])
    project = Project.find(params[:project][:id])
    list.listings.create item: project

    redirect_to :back
  end

  def remove_listing
    list = List.find(params[:id])
    list.listings.find_by_item_id(params[:project][:id]).destroy

    redirect_to :back
  end

  def show
    @list = ProjectList.find(params[:id])
    @group = @list.listable if @list.listable_type == 'Group'
    @projects = @list.sorted_projects(as_owner: @list.listable == current_user)
    if @projects.class.name == 'Array'
      @projects = Kaminari.paginate_array(@projects).page(params[:page]).per(12)
    else
      @projects = @projects.page(params[:page]).per(12)
    end
  end
end
