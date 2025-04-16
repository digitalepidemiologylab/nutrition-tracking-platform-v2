# frozen_string_literal: true

require "rails_helper"

RSpec.describe(UsersQuery, :freeze_time) do
  let!(:admin) { create(:collaborator, :admin) }

  let!(:user_1) { create(:user, email: "user__1@myfoodrepo.org", created_at: 1.day.ago) }
  let!(:participation_user_1) { create(:participation, user: user_1, key: participation_user_1_key) }
  let!(:participation_user_1_key) { "dPzTAM3Xg" }

  let!(:user_2) { create(:user, email: "user__2@myfoodrepo.org", created_at: 4.days.ago) }
  let!(:participation_user_2) { create(:participation, user: user_2, key: participation_user_2_key) }
  let!(:participation_user_2_key) { "w5d2uFAGR" }

  let!(:user_3) { create(:user, email: "user__3@myfoodrepo.org", created_at: 2.days.ago) }
  let!(:participation_user_3) { create(:participation, user: user_3, key: participation_user_3_key) }
  let!(:participation_user_3_key) { "agAk8z5y6" }

  let(:initial_scope) { User.all }
  let(:query_instance) {
    described_class.new(initial_scope: initial_scope, policy: Collab::UserPolicy.new(admin, User))
  }
  let(:result) { query_instance.query(params: ActionController::Parameters.new(params)) }

  describe "sorting" do
    context "when sort_by is nil" do
      let(:params) { {} }

      it "sorts by email :asc" do
        expect(result.to_a).to eq([user_1, user_2, user_3])
      end
    end

    context "when by email" do
      context "when direction asc" do
        let(:params) { {sort: "email", direction: "asc"} }

        it do
          expect(result.to_a).to eq([user_1, user_2, user_3])
        end
      end

      context "when direction desc" do
        let(:params) { {sort: "email", direction: "desc"} }

        it do
          expect(result.to_a).to eq([user_3, user_2, user_1])
        end
      end
    end

    context "when by created_at" do
      context "when direction asc" do
        let(:params) { {sort: "created_at", direction: "asc"} }

        it do
          expect(result.to_a).to eq([user_2, user_3, user_1])
        end
      end

      context "when direction desc" do
        let(:params) { {sort: "created_at", direction: "desc"} }

        it do
          expect(result.to_a).to eq([user_1, user_3, user_2])
        end
      end
    end
  end

  describe "#filtered" do
    context "when querying by email with 'user__2'" do
      let(:params) { {query: "user__2"} }

      it { expect(result.to_a).to eq([user_2]) }
    end

    context "when query by participation key" do
      let(:params) { {query: participation_user_3_key} }

      it { expect(result.to_a).to eq([user_3]) }
    end
  end
end
