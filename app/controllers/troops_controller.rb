class TroopsController < ApplicationController
  before_action :set_troop, only: [:edit, :update, :destroy]

  def create
    Group.transaction do
      current_group.register_new_troop(troop_params)
      current_group.save!
    end

    redirect_to current_group

  rescue ActiveRecord::RecordInvalid => e
    @troop = e.record
    render action: :edit
  end

  def edit
    @page_title = @troop.name
    render
  end

  def update
    @troop.update_attributes!(troop_params)
    redirect_to current_group

  rescue ActiveRecord::RecordInvalid => e
    render action: :edit
  end

  private

  def set_troop
    @troop = current_group.troops.find_by!(slug: params[:id])
  end

  def troop_params
    params.require(:troop).permit(:name, :position)
  end
end
