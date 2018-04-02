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
end
