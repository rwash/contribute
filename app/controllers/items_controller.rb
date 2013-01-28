class ItemsController < InheritedResources::Base
  load_and_authorize_resource

  def destroy
    @item = Item.find(params[:id])
    @item.destroy

    begin
      redirect_to :back
    rescue
      redirect_to :root
    end
  end
end
