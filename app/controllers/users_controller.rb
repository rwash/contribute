class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    authorize! :read, @user
  end

  def index
    @users = User.all
    # TODO this line should be:
    # authorize! :read, @users
    authorize! :read, User
  end

  def block
    @user = User.find(params[:id])
    authorize! :block, @user
  end

  def toggle_admin
    @user = User.find(params[:id])
    authorize! :toggle_admin, @user
  end

end
