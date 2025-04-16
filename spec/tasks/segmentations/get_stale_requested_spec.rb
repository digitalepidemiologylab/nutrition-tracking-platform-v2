# frozen_string_literal: true

require "rails_helper"

describe "segmentations" do # rubocop:disable RSpec/DescribeClass
  describe "get_stale_requested" do
    it do
      expect { Rake::Task["segmentations:get_stale_requested"].invoke }
        .to have_enqueued_job(Segmentations::GetAllStaleRequestedJob).with(no_args).once
    end
  end
end
