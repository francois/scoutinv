class MembersController < ApplicationController
  before_action :set_member, only: [:show, :edit, :update, :destroy]

  def edit
    @page_title = t(".page_title", member_name: @member.name)
  end

  def create
    current_group.transaction do
      current_group.register_new_member(member_params, metadata: domain_event_metadata)

      if current_group.save
        redirect_to current_group, notice: t(".member_successfully_created")
      else
        @page_title = t(".page_title")
        render :new
      end
    end
  end

  def update
    current_group.transaction do
      if @member.change_member_identification(member_params, metadata: domain_event_metadata)
        redirect_to current_group, notice: t(".member_successfully_updated")
      else
        @page_title = t(".page_title", member_name: @member.name)
        render :edit
      end
    end
  end

  def destroy
    @member.destroy
    redirect_to group_path(current_group), notice: I18n.t("members.destroy.notice")
  end

  private

  def set_member
    @member = current_group.members.find_by!(slug: params[:id])
  end

  def member_params
    params.require(:member).permit(:name, :email)
  end
end
