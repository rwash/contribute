class CommentsController < InheritedResources::Base
  def create
    @comment = Comment.new(params[:comment])
    
    if user_signed_in? #from devise, check their github page for more info
      @comment.user_id = current_user.id
      
      if @comment.save
        redirect_to :id => nil
      else
        render :action => "new"
      end
    
    else
      flash[:notice] = "You must be logged in to comment."
      redirect_to(comments_path)
    end
  end
  
  def destroy
    @comment = Comment.find(params[:id])

    if comment_owner(@comment) # def in application_controller.rb
            
      if !@comment.delete
        flash[:alert] = "Comment could not be deleted."
        return redirect_to @comment
      else 
        flash[:alert] = "Comment successfully deleted."
        return redirect_to comments_path
      end
      
      else
        flash[:alert] = "Can't delete other peoples comments."
        redirect_to comments_path
    end
  end
end
