class Products::ImagesController < ApplicationController
  before_action :set_product
  before_action :set_image

  def left
    rotate(-90)
    respond_to do |format|
      format.html { redirect_to @product }
      format.js   { render action: :redraw_image }
    end
  end

  def right
    rotate(90)
    respond_to do |format|
      format.html { redirect_to @product }
      format.js   { render action: :redraw_image }
    end
  end

  def destroy
    @image.destroy
    respond_to do |format|
      format.html { redirect_to @product, notice: I18n.t("products.images.destroy.notice") }
      format.js
    end
  end

  private

  def set_product
    @product = current_group.products.find_by!(slug: params[:product_id])
  end

  def set_image
    @image = @product.images.find(params[:id])
  end

  def rotate(angle)
    basename = Rails.root + "tmp/#{SecureRandom.uuid}.jpg"
    updname  = basename.sub(".jpg", "-updated.jpg")

    tf = File.new(basename, "w:ASCII-8BIT")
    tf.write(@image.download)
    tf.close

    img = MiniMagick::Image.new(tf.path)
    img.strip
    img.rotate(angle)
    img.quality(80)
    img.write(updname)

    File.open(updname) do |io|
      @new_image = @product.images.attach(io: io, filename: @image.filename).first
    end
    @image.destroy
  end
end
