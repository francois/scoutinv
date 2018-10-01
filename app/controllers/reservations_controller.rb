class ReservationsController < ApplicationController
  def update
    reservation = current_group.reservations.find_by!(slug: params[:id])
    message =
      if reservation.update(params.require(:reservation).permit(:unit_price))
        "OK"
      else
        "Oops"
      end

    respond_to do |format|
      format.html do
        redirect_to event_reservations_path(reservation.event, manage: "1"), notice: :message
      end
      format.js
    end
  end
end
