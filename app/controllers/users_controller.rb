class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @page_title = "Users"
    @users = current_group.users.all
  end

  def show
    @page_title = @user.name
  end

  def new
    @page_title = "New User"
    @user = current_group.users.build
  end

  def edit
    @page_title = "Edit #{@user.name}"
  end

  def create
    @user = current_user.group.users.build(user_params)

    if @user.save
      redirect_to @user, notice: 'User was successfully created.'
    else
      @page_title = "New User"
      render :new
    end
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      @page_title = "Edit #{@user.name}"
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url, notice: 'User was successfully destroyed.'
  end

  private

  def set_user
    @user = current_group.users.find_by!(slug: params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
