# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::ParticipationsController, :freeze_time) do
  let!(:collaborator_admin) { create(:collaborator, :admin) }
  let!(:cohort) { create(:cohort) }
  let!(:participation) { create(:participation, cohort: cohort) }

  before { sign_in(collaborator_admin) }

  describe "#index" do
    context "with cohort as parent" do
      it do
        get collab_cohort_participations_path(cohort)
        expect(response).to have_http_status(:success)
      end
    end

    context "with user as parent" do
      it do
        get collab_user_participations_path(participation.user)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "#edit" do
    it do
      get edit_collab_cohort_participation_path(cohort, participation)
      expect(response).to have_http_status(:success)
    end
  end

  describe "#update" do
    let(:request) { put collab_cohort_participation_path(cohort, participation), params: {participation: {ended_at: 1.hour.from_now}} }

    context "when successfull" do
      it do
        expect { request }.to change { participation.reload.ended_at }.from(1.week.from_now).to(1.hour.from_now)
        expect(response).to redirect_to(collab_cohort_path(cohort))
      end
    end

    context "with failed" do
      before do
        allow_any_instance_of(Participation).to receive(:update).with(any_args).and_return(false)
        allow_any_instance_of(Participation).to receive(:errors)
          .and_return(ActiveModel::Errors.new(participation).tap { |e| e.add(:base, "Failed") })
      end

      it do
        request
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "#destroy" do
    let(:request) { delete(collab_cohort_participation_path(cohort, participation), headers: turbo_stream_headers) }

    context "when successful" do
      it do
        expect { request }.to change(Participation, :count).by(-1)
        expect(response).to redirect_to(collab_cohort_path(cohort))
        expect(flash[:notice]).to eq("Participation deleted successfully")
      end
    end

    context "when failed" do
      before do
        allow_any_instance_of(Participation).to receive(:destroy).and_return(false)
      end

      it do
        expect { request }.not_to change(Participation, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("turbo-stream")
        expect(response.body).to include("Participation could not be deleted")
      end
    end
  end
end
