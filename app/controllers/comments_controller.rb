class CommentsController < InheritedResources::Base
  def create
    @comment = Comment.new(params[:comment])
    # @comment.userid = current_user.id
    if @comment.save
      redirect_to @comment
    else
      render :action => "new"
    end
  end
end
