class ConsumableTransactionsController < ApplicationController
  before_action :set_consumable

  def create
    @consumable.change_quantity(
      QuantityParser.new.parse(consumable_transaction_params[:quantity]),
      reason: consumable_transaction_params[:reason],
    )

    @consumable.save!
    redirect_to @consumable
  end

  def destroy
    @consumable.
      consumable_transactions.
      detect{|ct| ct.id.to_s == params[:id]}&.
      mark_for_destruction

    @consumable.save!
    redirect_to @consumable
  end

  private

  def set_consumable
    @consumable = current_group.consumables.find_by!(slug: params[:consumable_id])
  end

  def consumable_transaction_params
    params.require(:consumable_transaction).permit(:quantity, :reason)
  end
end
