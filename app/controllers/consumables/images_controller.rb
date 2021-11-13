class Consumables::ImagesController < ApplicationController
  before_action :set_consumable
  before_action :set_image

  def left
    rotate(-90)
    respond_to do |format|
      format.html { redirect_to @consumable }
      format.js   { render action: :redraw_image }
    end
  end

  def right
    rotate(90)
    respond_to do |format|
      format.html { redirect_to @consumable }
      format.js   { render action: :redraw_image }
    end
  end

  def destroy
    @image.destroy
    respond_to do |format|
      format.html { redirect_to @consumable, notice: I18n.t("consumables.images.destroy.notice") }
      format.js
    end
  end

  private

  def set_consumable
    @consumable = current_group.consumables.find_by!(slug: params[:consumable_id])
  end

  def set_image
    @image = @consumable.images.find(params[:id])
  end

  def rotate(angle)
    basename = Rails.root + "tmp/#{SecureRandom.uuid}.jpg"
    updname  = basename.sub(".jpg", "-updated.jpg")

    begin
      tf = File.new(basename, "w:ASCII-8BIT")
      tf.write(@image.download)
      tf.close

      img = MiniMagick::Image.new(tf.path)
      img.rotate(angle)
      img.write(updname)

      File.open(updname, "r:ASCII-8BIT") do |io|
        @new_image = @consumable.images.attach(io: io, filename: @image.filename).first
      end
      @image.destroy

      # Process this ASAP, because there's a human waiting for it now
      ShrinkImageJob.set(priority: 0).enqueue(@consumable.id, @new_image.id)
    ensure
      File.unlink(basename) if File.exist?(basename)
      File.unlink(updname) if File.exist?(updname)
    end
  end
end
