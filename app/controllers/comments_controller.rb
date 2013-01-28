class CommentsController < InheritedResources::Base
  def create
    @project = Project.find(params[:projectid])

    if user_signed_in? #from devise, check their github page for more info
      @comment = Comment.build_from( @project, current_user.id, params[:comment][:body] )

      @comment.user = current_user

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

  # TODO: change action name to 'destroy'
  def delete
    @comment = Comment.find(params[:id])

    if comment_owner(@comment) # def in application_controller.rb
      if(@comment.children.any?)
        @comment.body = "[comment deleted]"
        @comment.save
      else
        if !@comment.delete
          flash[:alert] = "Comment could not be deleted."
        else
          flash[:alert] = "Comment successfully deleted."
        end
      end

    else
      flash[:alert] = "You cannot delete comments you don't own."
    end

    begin
      redirect_to :back
    rescue
      redirect_to :root
    end
  end

end
