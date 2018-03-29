class HomeController < PublicController
  def show
    if user_signed_in?
      @page_title = "Home"
      @products   = current_group.products.not_recently_reserved.limit(10)
      @events     = current_group.events.after(2.weeks.ago)
      render action: "authenticated"
    else
      @page_title = nil
      render action: "anonymous"
    end
  end
end
