# frozen_string_literal: true

namespace :segmentations do
  desc "get segmentation data from service for stale requested segmentations"
  task get_stale_requested: :environment do
    Segmentations::GetAllStaleRequestedJob.perform_later
  end
end
