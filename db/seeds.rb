# frozen_string_literal: true

# To re-seed your DB with anonimyzed data, call rails db:seed`
ActionMailer::Base.perform_deliveries = false
ENV["SEEDING"] = "true"
review_app = ENV["REVIEW_APP"].present?


Seeds::Service.new.call(review_app: review_app)
