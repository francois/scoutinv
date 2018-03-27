class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy]

  def index
    @page_title = "Groups"
    @groups = Group.all
  end

  def show
    @page_title = @group.name
  end

  def new
    @page_title = "New Group"
    @group = Group.new
  end

  def edit
    @page_title = "Edit #{@group.name}"
  end

  def create
    @group = Group.new(group_params)

    if @group.save
      redirect_to @group, notice: 'Group was successfully created.'
    else
      @page_title = "Groups"
      render :new
    end
  end

  def update
    if @group.update(group_params)
      redirect_to @group, notice: 'Group was successfully updated.'
    else
      @page_title = "Edit #{@group.name}"
      render :edit
    end
  end

  def destroy
    @group.destroy
    respond_to do |format|
      redirect_to groups_url, notice: 'Group was successfully destroyed.'
    end
  end

  private
  def set_group
    @group = Group.find_by!(slug: params[:id])
  end

  def group_params
    params.require(:group).permit(:name)
  end
end
