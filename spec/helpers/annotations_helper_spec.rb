# frozen_string_literal: true

require "rails_helper"

describe(AnnotationsHelper) do
  describe "#last_consumed_at_in_timezone(annotation:)", :freeze_time do
    let(:participation) { create(:participation, started_at: "2022-02-22 18:00", ended_at: "2022-02-24 12:22") }
    let(:annotation) { create(:annotation, participation: participation, intakes: [intake_1, intake_2]) }
    let(:intake_1) { build(:intake, consumed_at: "2022-02-22 22:22", timezone: "EST", annotation: nil) }
    let(:intake_2) { build(:intake, consumed_at: "2022-02-23 22:22", timezone: "EST", annotation: nil) }

    it "returns a span with the last consumed at date and timezone" do
      expect(helper.last_consumed_at_in_timezone(annotation: annotation))
        .to eq("<span>February 23, 2022 17:22 (EST)</span>")
    end
  end
end
