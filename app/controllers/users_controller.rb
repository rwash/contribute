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
    user = User.find(params[:id])
    authorize! :block, user

    # TODO

    redirect_to user, notice: 'user not blocked yet'
  end

  def toggle_admin
    user = User.find(params[:id])
    authorize! :toggle_admin, user

    # TODO

    redirect_to user, notice: 'User not yet promoted to admin status'
  end

end
