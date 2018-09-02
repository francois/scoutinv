class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM")
  layout "mailer"

  add_template_helper ProductHelper
  add_template_helper EventHelper
end
