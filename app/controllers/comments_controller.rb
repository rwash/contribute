class CommentsController < InheritedResources::Base
  before_filter :authenticate_user!

  def create
    project = Project.find(params[:projectid])

    comment = Comment.new(project: project, user: current_user, body: params[:comment][:body])
    comment.user = current_user
    authorize! :create, comment

    if comment.valid?
      comment.save
      log_user_action :create, comment
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

    authorize! :destroy, comment, message: "You cannot delete comments you don't own."

    if comment.delete
      flash[:alert] = "Comment successfully deleted."
    else
      flash[:alert] = "Comment could not be deleted."
    end

    begin
      redirect_to :back
    rescue
      redirect_to :root
    end
  end

  private
  def log_user_action event, comment
    UserAction.create user: current_user, subject: comment, event: event
  end
end
