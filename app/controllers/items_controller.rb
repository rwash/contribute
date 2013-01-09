class ItemsController < InheritedResources::Base
  def destroy
    @item = Item.find(params[:id])
    @item.destroy

    redirect_to :back
  end
end
