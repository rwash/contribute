class ListingsController < InheritedResources::Base
  load_and_authorize_resource

  def destroy
    listing = Listing.find(params[:id])
    listing.destroy

    begin
      redirect_to :back
    rescue
      redirect_to :root
    end
  end

  def sort
    params[:project_listing].each_with_index do |id, index|
      ProjectListing.update_all({position: index + 1}, id: id)
    end
    render nothing: true
  end

end
