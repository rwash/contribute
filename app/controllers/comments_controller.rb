class CommentsController < InheritedResources::Base
  before_filter :authenticate_user!

  def create
    project = Project.find(params[:projectid])

    comment = Comment.new(commentable: project, user: current_user, body: params[:comment][:body])
    comment.user = current_user
    authorize! :create, comment

    if comment.valid?
      comment.save
      redirect_to project

      if(params[:parentCommentId] != nil)
        parentComment = Comment.find(params[:parentCommentId])
        comment.move_to_child_of(parentComment)
      end

    else
      redirect_to project
    end
  end

  # TODO: change action name to 'destroy'
  def delete
    comment = Comment.find(params[:id])

    authorize! :destroy, comment, message: "You cannot delete comments you don't own."

    if(comment.children.any?)
      comment.body = "[comment deleted]"
      comment.save
    else
      if !comment.delete
        flash[:alert] = "Comment could not be deleted."
      else
        flash[:alert] = "Comment successfully deleted."
      end
    end

    begin
      redirect_to :back
    rescue
      redirect_to :root
    end
  end

end
