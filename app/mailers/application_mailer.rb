class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM")
  layout "mailer"

  helper ProductHelper
  helper EventHelper
end
