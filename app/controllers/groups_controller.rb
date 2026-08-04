class GroupsController < ApplicationController
  include SanitizesImages

  before_action :set_group, only: [:show, :edit, :update, :destroy]

  def index
    @page_title = t(".page_title")

    @groups = Group.all
  end

  def show
    @page_title = @group.name

    @member = @group.members.build
    @troop  = @group.troops.build
  end

  def new
    @page_title = t(".page_title")

    @group = Group.new
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
  rescue ImageSanitizer::Error
    @group ||= Group.new
    @group.errors.add(:logo, :unsupported_image)
    @page_title = t(".page_title")
    render :new, status: :unprocessable_content
  ensure
    close_sanitized_images
  end

  def update
    if @group.update(group_params)
      redirect_to @group, notice: t(".group_successfully_updated")
    else
      @page_title = t(".page_title", group_name: @group.name)
      render :edit
    end
  rescue ImageSanitizer::Error
    @group.errors.add(:logo, :unsupported_image)
    @page_title = t(".page_title", group_name: @group.name)
    render :edit, status: :unprocessable_content
  ensure
    close_sanitized_images
  end

  def destroy
    @group.destroy
    respond_to do |format|
      redirect_to groups_url, notice: t(".group_successfully_destroyed")
    end
  end

  private

  def set_group
    @group = current_group
  end

  def group_params
    permitted = params.require(:group).permit(:name, :logo, :address)
    permitted[:logo] = sanitize_image(permitted[:logo]) if permitted[:logo].present?
    permitted
  end
end
