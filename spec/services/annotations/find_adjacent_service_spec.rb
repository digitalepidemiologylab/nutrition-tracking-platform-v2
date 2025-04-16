# frozen_string_literal: true

require "rails_helper"

describe(Annotations::FindAdjacentService) do
  let(:collaborator) { create(:collaborator, :admin) }
  let!(:participation) { create(:participation, started_at: 1.day.ago, ended_at: 1.day.from_now) }
  let(:dish) { create(:dish, annotations: [annotation_1]) }
  let!(:annotation_1) { build(:annotation, participation: participation, intakes: build_list(:intake, 1, consumed_at: 12.hours.ago, annotation: nil), dish: nil) }
  let!(:annotation_2) { create(:annotation, participation: participation, intakes: build_list(:intake, 1, consumed_at: 9.hours.ago, annotation: nil), dish: dish) }
  let!(:annotation_3) { create(:annotation, participation: participation, intakes: build_list(:intake, 1, consumed_at: 10.hours.ago, annotation: nil), dish: dish) }
  let!(:annotation_4) { create(:annotation, participation: participation, intakes: build_list(:intake, 1, consumed_at: 8.hours.ago, annotation: nil), dish: dish) }
  let!(:annotation_5) { create(:annotation, participation: participation, intakes: build_list(:intake, 1, consumed_at: 7.hours.ago, annotation: nil), dish: dish) }
  let!(:annotation_6) { create(:annotation, participation: participation, intakes: build_list(:intake, 1, consumed_at: 11.hours.ago, annotation: nil), dish: dish) }
  let(:service_1) { described_class.new(annotation: annotation_1, collaborator: collaborator) }
  let(:service_2) { described_class.new(annotation: annotation_2, collaborator: collaborator) }
  let(:service_3) { described_class.new(annotation: annotation_3, collaborator: collaborator) }
  let(:service_4) { described_class.new(annotation: annotation_4, collaborator: collaborator) }
  let(:service_5) { described_class.new(annotation: annotation_5, collaborator: collaborator) }
  let(:service_6) { described_class.new(annotation: annotation_6, collaborator: collaborator) }

  describe "#call" do
    it do
      expect(service_1.call).to eq({previous: [], next: [annotation_6, annotation_3, annotation_2]})
      expect(service_2.call).to eq({previous: [annotation_1, annotation_6, annotation_3], next: [annotation_4, annotation_5]})
      expect(service_3.call).to eq({previous: [annotation_1, annotation_6], next: [annotation_2, annotation_4, annotation_5]})
      expect(service_4.call).to eq({previous: [annotation_6, annotation_3, annotation_2], next: [annotation_5]})
      expect(service_5.call).to eq({previous: [annotation_3, annotation_2, annotation_4], next: []})
      expect(service_6.call).to eq({previous: [annotation_1], next: [annotation_3, annotation_2, annotation_4]})
    end
  end
end
