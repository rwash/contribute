class UpdatesController < InheritedResources::Base
  before_filter :authenticate_user!

  def create
    project = Project.find(params[:project_id])
    update = project.updates.new(params[:update])
    authorize! :create, update
    update.project = project
    update.email_sent = false

    update.user = current_user
    if update.save
      flash[:notice] = t('updates.create.success.flash')
    else
      flash[:alert] = t('updates.create.failure.flash')
    end
    redirect_to project
  end

end
