# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Collab::Participations::ResettersController) do
  let!(:collaborator_admin) { create(:collaborator, :admin) }
  let!(:participation) { create(:participation) }

  before { sign_in(collaborator_admin) }

  describe "#create" do
    context "with turbo_stream format" do
      let(:request) do
        post(collab_participation_resetter_path(participation), headers: turbo_stream_headers)
      end

      context "when successful" do
        before { allow_any_instance_of(Participations::ResetService).to receive(:call).and_return(true) }

        it do
          request
          expect(response.body).to match("<turbo-stream action=\"update\"")
          expect(flash[:notice]).to eq("Successfully reset association date")
        end
      end

      context "when failed" do
        before do
          allow_any_instance_of(Participations::ResetService).to receive(:call).and_return(false)
          allow_any_instance_of(Participations::ResetService)
            .to receive(:errors)
            .and_return(ActiveModel::Errors.new(Participations::ResetService.new(participation: participation))
            .tap { |e| e.add(:base, "Failed") })
        end

        it do
          request
          expect(response.body).to match("<turbo-stream action=\"update\"")
          expect(flash[:alert]).to eq("Failed")
        end
      end
    end
  end
end
