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

  # TODO: Set a flag in the model? Possibly use the acts_as_paranoid gem
  def destroy
    comment = Comment.find(params[:id])

    authorize! :destroy, comment

    if(comment.children.any?)
      comment.body = t('comments.deleted')
      comment.save
    else
      if comment.delete
        flash[:alert] = t('comments.destroy.success.flash')
      else
        flash[:alert] = t('comments.destroy.failure.flash')
      end
    end

    begin
      redirect_to :back
    rescue
      redirect_to :root
    end
  end

end
