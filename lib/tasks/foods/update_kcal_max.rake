# frozen_string_literal: true

namespace :foods do
  namespace :update_kcal_max do
    desc "Update kcal thresholds of all foods"
    task all: :environment do
      Foods::UpdateKcalMaxService.new.call
    end

    desc "Update kcal thresholds of foods annotated in the last 2 days"
    task last_2_days: :environment do
      Foods::UpdateKcalMaxService.new.call(datetime: 2.days.ago)
    end
  end
end
