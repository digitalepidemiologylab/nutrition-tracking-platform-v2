# frozen_string_literal: true

require "rails_helper"

describe(AnnotationsQuery, :freeze_time) do
  let!(:cohort_1) { create(:cohort) }
  let!(:cohort_2) { create(:cohort) }
  let!(:cohort_3) { create(:cohort) }

  let!(:collaborator) { create(:collaborator) }
  let!(:collaboration_1) { create(:collaboration, :manager, collaborator: collaborator, cohort: cohort_1) }
  let!(:collaboration_2) { create(:collaboration, :annotator, collaborator: collaborator, cohort: cohort_2) }

  let!(:user_1) { create(:user, participations: [build(:participation, cohort: cohort_1, started_at: 5.days.ago)]) }
  let!(:user_2) { create(:user, participations: [build(:participation, cohort: cohort_2, started_at: 5.days.ago)]) }
  let!(:user_3) { create(:user, participations: [build(:participation, cohort: cohort_3, started_at: 5.days.ago)]) }

  let(:participation_1) { user_1.current_participation }
  let(:participation_2) { user_2.current_participation }
  let(:participation_3) { user_3.current_participation }

  let!(:dish_1) { create(:dish, user: user_1, annotations: [annotation_1]) }
  let!(:dish_2) { create(:dish, user: user_2, annotations: [annotation_2]) }
  let!(:dish_3) { create(:dish, user: user_3, annotations: [annotation_3]) }

  let!(:intake_1) { build(:intake, consumed_at: 2.days.ago) }
  let!(:intake_2) { build(:intake, consumed_at: 1.day.ago) }
  let!(:intake_3) { build(:intake, consumed_at: 3.days.ago) }

  let!(:annotation_1) { build(:annotation, participation: participation_1, dish: nil, intakes: [intake_1], created_at: 1.minute.ago) }
  let!(:annotation_2) { build(:annotation, participation: participation_2, dish: nil, intakes: [intake_2], created_at: 30.seconds.ago) }
  let!(:annotation_3) { build(:annotation, participation: participation_3, dish: nil, intakes: [intake_3]) }

  let(:initial_scope) { Annotation.all }
  let(:query_instance) {
    described_class.new(initial_scope: initial_scope, policy: Collab::AnnotationPolicy.new(collaborator, Annotation))
  }
  let(:result) { query_instance.query(params: ActionController::Parameters.new(params)) }

  before do
    annotation_2.ask_info!
  end

  describe "filtering" do
    describe "by status" do
      context "when status exists" do
        let(:params) { {filter: {status: "info_asked"}} }

        it { expect(result.to_a).to eq([annotation_2]) }
      end

      context "when status doesn't exist" do
        let(:params) { {filter: {status: "unknown"}} }

        it { expect { result }.to raise_error(BaseQuery::BadFilterParam, "Status not supported") }
      end

      context "when status == 'All'" do
        let(:params) { {filter: {status: "All"}} }

        it { expect(result.to_a).to contain_exactly(annotation_1, annotation_2, annotation_3) }
      end
    end

    describe "by cohort_id" do
      context "when cohort exists" do
        let(:params) { {filter: {cohort_id: cohort_2.id}} }

        it { expect(result.to_a).to eq([annotation_2]) }
      end

      context "when cohort doesn't exist" do
        let(:params) { {filter: {cohort_id: "unknown"}} }

        it { expect(result.to_a).to be_empty }
      end

      context "when cohort_id == 'All'" do
        let(:params) { {filter: {cohort_id: "All"}} }

        it { expect(result.to_a).to contain_exactly(annotation_1, annotation_2, annotation_3) }
      end

      context "when cohort_id == 'None'" do
        let(:params) { {filter: {cohort_id: "none"}} }

        it { expect(result.to_a).to be_empty }
      end
    end
  end

  describe "sorting" do
    context "when sort_by is nil" do
      let(:params) { {} }

      it "sorts by :consumed_at desc by default" do
        expect(result.to_a).to eq([annotation_2, annotation_1, annotation_3])
      end
    end

    context "when by status" do
      context "when direction asc" do
        let(:params) { {sort: "status", direction: "asc"} }

        it do
          expect(result.to_a).to eq([annotation_3, annotation_1, annotation_2])
        end
      end

      context "when direction desc" do
        let(:params) { {sort: "status", direction: "desc"} }

        it do
          expect(result.to_a).to eq([annotation_2, annotation_3, annotation_1])
        end
      end
    end

    context "when by consumed_at" do
      context "when direction asc" do
        let(:params) { {sort: "consumed_at", direction: "asc"} }

        it do
          expect(result.to_a).to eq([annotation_3, annotation_1, annotation_2])
        end
      end

      context "when direction desc" do
        let(:params) { {sort: "consumed_at", direction: "desc"} }

        it do
          expect(result.to_a).to eq([annotation_2, annotation_1, annotation_3])
        end
      end
    end

    context "when attributes is not permitted" do
      let(:params) { {sort: "not_permitted", direction: "asc"} }

      it "sorts by :consumed_at by default" do
        expect(result.to_a).to eq([annotation_3, annotation_1, annotation_2])
      end
    end
  end
end
