class Products::InstancesController < ApplicationController
  before_action :set_product
  before_action :set_instance

  def hold
    @instance.hold!(metadata: domain_event_metadata)
    respond_to do |format|
      format.html { redirect_to @product, notice: t("products.instances.sent_for_repairs_notice", serial_no: @instance.serial_no) }
      format.js { render action: :refresh_instance_row }
    end
  end

  def send_for_repairs
    @instance.send_for_repairs!(metadata: domain_event_metadata)
    respond_to do |format|
      format.html { redirect_to @product, notice: t("products.instances.sent_for_repairs_notice", serial_no: @instance.serial_no) }
      format.js { render action: :refresh_instance_row }
    end
  end

  def repair
    @instance.repair!(metadata: domain_event_metadata)
    respond_to do |format|
      format.html { redirect_to @product, notice: t("products.instances.repaired_notice", serial_no: @instance.serial_no) }
      format.js { render action: :refresh_instance_row }
    end
  end

  def destroy
    @instance.trash!(metadata: domain_event_metadata)
    respond_to do |format|
      format.html { redirect_to @product, notice: t("products.instances.trashed_notice", serial_no: @instance.serial_no) }
      format.js { render action: :refresh_instance_row }
    end
  end

  private

  def set_product
    @product = current_group.products.find_by!(slug: params[:product_id])
  end

  def set_instance
    @instance = @product.instances.find_by!(slug: params[:id])
  end
end
