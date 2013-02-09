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

    # TODO

    redirect_to user, notice: 'user not blocked yet'
  end

  def toggle_admin
    user = User.find(params[:id])
    authorize! :toggle_admin, user

    redirect_to :back and return if params[:admin].nil?
    user.admin = params[:admin]

    if user.save
      redirect_to :back, notice: "#{user.name}'s privileges were successfully updated"
    else
      redirect_to :back, notice: "Failed to save changes to #{user.name}'s account"
    end
  end

end
