class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy]

  def index
    @page_title = t(".page_title")
    @groups = Group.all
  end

  def show
    @page_title = @group.name
    @member     = @group.members.build
  end

  def new
    @page_title = t(".page_title")
    @group      = Group.new
  end

  def edit
    @page_title = t(".page_title", group_name: @group.name)
  end

  def create
    @group = Group.new(group_params)

    if @group.save
      redirect_to @group, notice: t(".group_successfully_created")
    else
      @page_title = t(".page_title")
      render :new
    end
  end

  def update
    if @group.update(group_params)
      redirect_to @group, notice: t(".group_successfully_updated")
    else
      @page_title = t(".page_title", group_name: @group.name)
      render :edit
    end
  end

  def destroy
    @group.destroy
    respond_to do |format|
      redirect_to groups_url, notice: t(".group_successfully_destroyed")
    end
  end

  private
  def set_group
    @group = Group.find_by!(slug: params[:id])
  end

  def group_params
    params.require(:group).permit(:name, :logo)
  end
end
