class InstancesController < ApplicationController
  def edit
    @instance = current_group
      .instances
      .includes(:product)
      .find_by!(slug: params[:id])

    render
  end

  def update
    @instance = current_group
      .instances
      .includes(:product)
      .find_by!(slug: params[:id])

    if @instance.update!(instance_params)
      redirect_to @instance.product
    else
      render action: :edit
    end
  end

  private

  def instance_params
    params.require(:instance).permit(:serial_no)
  end
end
