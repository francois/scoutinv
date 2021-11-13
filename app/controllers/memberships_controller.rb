class MembershipsController < ApplicationController
  def create
    membership_params = params.require(:membership).permit(:email, :troop_slug)
    troop = current_group.troops.detect{|troop| troop.slug == membership_params[:troop_slug]}
    troop.members << Member.find_by!(email: membership_params[:email])
    redirect_to current_group, notice: t("memberships.attached_to_troop", email: membership_params[:email], troop_name: troop.name)
  end

  def destroy
    membership = Membership.where(slug: params[:id]).first
    raise ActiveRecord::RecordNotFound unless membership

    membership.destroy if membership.troop.group.slug == params[:group_id]
    redirect_to current_group, notice: t("memberships.removed_from_troop", email: membership.member.email, troop_name: membership.troop.name)
  end

  private

end
