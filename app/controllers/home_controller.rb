# frozen_string_literal: true

class HomeController < PublicController
  def show
    if member_signed_in?
      @page_title = I18n.t("page_title", scope: "home")
      @products   = current_group.products.not_recently_reserved.limit(10)
      @events     = current_group.events.after(2.weeks.ago)
      render action: "authenticated"
    else
      @page_title = nil
      render action: "anonymous"
    end
  end

  VALID_SIZES = %w[ 192x192 180x180 152x152 144x144 120x120 114x114 76x76 72x72 57x57 ].map(&:freeze).freeze

  def apple_touch_icon
    return render text: "not found", type: :text, layout: false, status: :bad_request unless VALID_SIZES.include?(params[:size])

    if current_group && current_group.logo.attached?
      redirect_to url_for(current_group.logo.variant(resize: params[:size], format: "png"))
    else
      render text: "not found", type: :text, layout: false, status: :not_found
    end
  end
end
