class CommentsController < InheritedResources::Base
  def create
    @project = Project.find(params[:projectid])
    @comment = Comment.build_from( @project, current_user.id, params[:comment][:body] )
    

    
    if user_signed_in? #from devise, check their github page for more info
      @comment.user_id = current_user.id
      
      if @comment.valid?
        @comment.save
        redirect_to @project
        
        if(params[:parentCommentId] != nil)
          @parentComment = Comment.find(params[:parentCommentId])
          @comment.move_to_child_of(@parentComment)
        end
        
      else
        redirect_to @project
      end
    
    else
      flash[:notice] = "You must be logged in to comment."
      redirect_to(comments_path)
    end
  end
  
  def delete
    @comment = Comment.find(params[:id])

    if comment_owner(@comment) # def in application_controller.rb
            
      if !@comment.delete
        flash[:notice] = "Comment could not be deleted."
      else 
        @comment.body == "[comment deleted]"
        flash[:notice] = "Comment successfully deleted."
      end
      
    else
      flash[:notice] = "Can't delete other peoples comments."
    end
    
    redirect_to :back
  end
  
end
