class ReportsController < ApplicationController
  before_action :authorize!

  def index
    @page_title = t("reports.page_title")
    render
  end

  def show
    case params[:id]
    when "leased"
      @page_title = t("reports.leased.page_title")
      @report = Reports::Leased.new(current_group)
      render action: :leased

    when "unavailable"
      @page_title = t("reports.unavailable.page_title")
      @report = Reports::Unavailable.new(current_group)
      render action: :unavailable

    else
      render text: "Not Found", status: :not_found
    end
  end

  private

  def authorize!
    return if current_member.inventory_director?
    render text: "Unauthorized", status: :unauthorized
  end
end
