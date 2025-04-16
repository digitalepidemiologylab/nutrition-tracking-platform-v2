# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "support@myfoodrepo.org"
  layout "mailer"
end
