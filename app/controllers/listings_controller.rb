class ListingsController < InheritedResources::Base
  load_and_authorize_resource

  def destroy
    @listing = Listing.find(params[:id])
    @listing.destroy

    begin
      redirect_to :back
    rescue
      redirect_to :root
    end
  end
end
