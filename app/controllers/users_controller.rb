class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    authorize! :read, @user
  end

  def edit
    @user = User.find(params[:id])
    authorize! :edit, @user
  end

  def index
    @users = User.all
    # TODO this line should be:
    # authorize! :read, @users
    authorize! :read, User
  end

  def block
    user = User.find(params[:id])
    authorize! :block, user

    redirect_to :back and return if params[:blocked].nil?
    user.blocked = params[:blocked]

    if user.save
      redirect_to :back, notice: t('users.modify_privileges.success.flash', username: user.name)
    else
      redirect_to :back, notice: t('users.modify_privileges.failure.flash', username: user.name)
    end
  end

  def toggle_admin
    user = User.find(params[:id])
    authorize! :toggle_admin, user

    redirect_to :back and return if params[:admin].nil?
    user.admin = params[:admin]

    if user.save
      redirect_to :back, notice: t('users.modify_privileges.success.flash', username: user.name)
    else
      redirect_to :back, notice: t('users.modify_privileges.failure.flash', username: user.name)
    end
  end

end
