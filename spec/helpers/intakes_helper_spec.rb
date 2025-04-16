# frozen_string_literal: true

require "rails_helper"

describe(IntakesHelper) do
  describe "#consumed_at_in_timezone(intake:)", :freeze_time do
    let(:participation) { create(:participation, started_at: "2022-02-22 18:00", ended_at: "2022-02-24 12:22") }
    let(:annotation) { create(:annotation, participation: participation, intakes: [intake_1, intake_2]) }
    let(:intake_1) { build(:intake, consumed_at: "2022-02-22 22:22", timezone: "Asia/Baghdad", annotation: nil) }
    let(:intake_2) { build(:intake, consumed_at: "2022-02-23 22:22", timezone: "EST", annotation: nil) }

    it "returns a span with the last consumed at date and timezone" do
      expect(helper.consumed_at_in_timezone(intake: intake_1))
        .to eq("<span>February 23, 2022 01:22 (Asia/Baghdad)</span>")
      expect(helper.consumed_at_in_timezone(intake: intake_2))
        .to eq("<span>February 23, 2022 17:22 (EST)</span>")
    end
  end
end
