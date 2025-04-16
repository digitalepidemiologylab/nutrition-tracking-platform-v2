# frozen_string_literal: true

require "rails_helper"

describe(Intakes::RetrieveDestroyedService) do
  let(:service) { described_class.new(params: params, user: user) }

  describe "#call" do
    let!(:intake) { create(:intake) }
    let!(:destroyed_intake_1) { create(:intake) }
    let!(:destroyed_intake_2) { create(:intake) }
    let(:paper_trail_version_intake_1) { PaperTrail::Version.find_by(item_id: destroyed_intake_1.id) }
    let(:paper_trail_version_intake_2) { PaperTrail::Version.find_by(item_id: destroyed_intake_2.id) }

    before do
      with_versioning do
        PaperTrail.request(whodunnit: "John Doe") do
          destroyed_intake_1.destroy
          destroyed_intake_2.destroy
        end
      end
      paper_trail_version_intake_2.update(created_at: 1.day.ago)
    end

    context "with no filter" do
      let(:params) { {} }
      let(:user) { nil }

      it { expect(service.call).to contain_exactly(paper_trail_version_intake_1, paper_trail_version_intake_2) }
    end

    context "with user filter" do
      let(:params) { {} }
      let(:user) { destroyed_intake_2.annotation.dish.user }

      it { expect(service.call).to contain_exactly(paper_trail_version_intake_2) }
    end

    context "with valid updated_at_gt filter" do
      let(:params) { {filter: {updated_at_gt: 20.hours.ago}} }
      let(:user) { nil }

      it { expect(service.call).to contain_exactly(paper_trail_version_intake_1) }
    end

    context "with invalid updated_at_gt filter" do
      let(:params) { {filter: {updated_at_gt: "invalid"}} }
      let(:user) { nil }

      it { expect { service.call }.to raise_error(BaseQuery::BadFilterParam) }
    end
  end
end
